import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';

import 'package:picksy/l10n/app_localizations.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

enum _Phase { idle, countdown, running, result }

class TapChallengePage extends StatefulWidget {
  const TapChallengePage({super.key});

  @override
  State<TapChallengePage> createState() => _TapChallengePageState();
}

class _TapChallengePageState extends State<TapChallengePage> {
  _Phase _phase = _Phase.idle;

  // Countdown
  int _countdownValue = 3;
  Timer? _countdownTimer;

  // Running
  int _tapsCount = 0;
  int _durationSeconds = 5;
  int _remainingMs = 0;
  Timer? _runTimer;
  Timer? _tickTimer;
  DateTime? _runStart;

  // Settings
  bool _vibrateOnGo = true;
  bool _vibrateOnEnd = true;

  // Result
  int? _lastTaps;
  double? _lastTPS;
  int? _personalBest; // in taps

  static const List<int> _proDurations = [5, 10, 15, 30, 60];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _runTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _countdownTimer?.cancel();
    _runTimer?.cancel();
    _tickTimer?.cancel();
    setState(() {
      _phase = _Phase.idle;
      _countdownValue = 3;
      _tapsCount = 0;
      _remainingMs = _durationSeconds * 1000;
    });
  }

  Future<void> _startCountdown() async {
    _countdownTimer?.cancel();
    _runTimer?.cancel();
    _tickTimer?.cancel();
    setState(() {
      _phase = _Phase.countdown;
      _countdownValue = 3;
      _tapsCount = 0;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
      } else if (_countdownValue == 1) {
        // Show "GO!" (value = 0) for a brief moment, then start run
        setState(() => _countdownValue = 0);
        t.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _startRun();
        });
      }
    });
  }

  Future<void> _startRun() async {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.running;
      _tapsCount = 0;
      _remainingMs = _durationSeconds * 1000;
      _runStart = DateTime.now();
    });

    if (_vibrateOnGo) {
      final hasV = await Vibration.hasVibrator() ?? false;
      if (hasV) Vibration.vibrate(duration: 100);
    }

    // Tick every 100ms for smooth countdown display
    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final elapsed = DateTime.now().difference(_runStart!).inMilliseconds;
      final remaining = (_durationSeconds * 1000) - elapsed;
      setState(() => _remainingMs = remaining.clamp(0, _durationSeconds * 1000));
    });

    _runTimer = Timer(Duration(seconds: _durationSeconds), () {
      if (!mounted) return;
      _endRun();
    });
  }

  Future<void> _endRun() async {
    _tickTimer?.cancel();
    _runTimer?.cancel();

    final taps = _tapsCount;
    final tps = taps / _durationSeconds;

    // Update personal best
    if (_personalBest == null || taps > _personalBest!) {
      _personalBest = taps;
    }

    if (!mounted) return;
    setState(() {
      _phase = _Phase.result;
      _lastTaps = taps;
      _lastTPS = tps;
      _remainingMs = 0;
    });

    // Save to history
    if (mounted) {
      final history = context.read<HistoryStore>();
      final gate = context.gateRead;
      await history.add(
        type: GeneratorType.tapChallenge,
        value: '$taps taps',
        maxEntries: gate.historyMax,
        metadata: {
          'tapsCount': taps,
          'durationSeconds': _durationSeconds,
          'tapsPerSecond': double.parse(tps.toStringAsFixed(2)),
        },
      );
    }

    if (_vibrateOnEnd) {
      final hasV = await Vibration.hasVibrator() ?? false;
      if (hasV) Vibration.vibrate(duration: 300);
    }
  }

  void _onTap() {
    if (_phase == _Phase.running) {
      setState(() => _tapsCount++);
    }
  }

  Color _bgColor(BuildContext context) {
    if (_phase == _Phase.running) {
      return GeneratorType.tapChallenge.accentColor.withOpacity(0.12);
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.tapChallenge.accentColor;

    return Scaffold(
      backgroundColor: _bgColor(context),
      appBar: AppBar(
        title: Text(l10n.tapChallengeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.analyticsTitle,
            onPressed: () {
              if (gate.canUse(ProFeature.analyticsAccess)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GeneratorAnalyticsPage(
                      generatorType: GeneratorType.tapChallenge,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.tapChallenge,
                );
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildMainCard(l10n, accent),
              const SizedBox(height: 16),
              _buildControls(l10n, gate, accent),
              const Spacer(),
              _buildButtons(l10n, accent),
              const SizedBox(height: 8),
              if (_phase == _Phase.running)
                Text(
                  l10n.tapChallengeInstructions,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(AppLocalizations l10n, Color accent) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: AppStyles.generatorResultCard(accent),
      child: _buildCardContent(l10n, accent),
    );
  }

  Widget _buildCardContent(AppLocalizations l10n, Color accent) {
    switch (_phase) {
      case _Phase.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: accent),
            const SizedBox(height: 12),
            Text(
              l10n.tapChallengeTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapChallengeInstructions,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.countdown:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.tapChallengeGetReady,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _countdownValue > 0 ? '$_countdownValue' : l10n.tapChallengeGo,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.running:
        final remainingSec = (_remainingMs / 1000).ceil();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_tapsCount',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.tapChallengeTaps,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _remainingMs / (_durationSeconds * 1000),
              color: accent,
              backgroundColor: accent.withOpacity(0.2),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Text(
              '${remainingSec}s',
              style: TextStyle(fontSize: 14, color: accent),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.result:
        final tps = _lastTPS?.toStringAsFixed(2) ?? '0.00';
        final best = _personalBest;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.tapChallengeResultTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultStat(
                  label: l10n.tapChallengeTaps,
                  value: '${_lastTaps ?? 0}',
                  accent: accent,
                ),
                _ResultStat(
                  label: l10n.tapChallengeTPS,
                  value: tps,
                  accent: accent,
                ),
                if (best != null)
                  _ResultStat(
                    label: l10n.tapChallengePersonalBest,
                    value: '$best',
                    accent: accent,
                    highlight: _lastTaps == best,
                  ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildControls(AppLocalizations l10n, FeatureGate gate, Color accent) {
    if (_phase != _Phase.idle && _phase != _Phase.result) {
      return const SizedBox.shrink();
    }

    final canChangeDuration = gate.canUse(ProFeature.tapChallengeDuration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration selector
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tapChallengeDurationLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (!canChangeDuration)
                        Text(
                          l10n.commonProFeature,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (canChangeDuration)
                  DropdownButton<int>(
                    value: _durationSeconds,
                    underline: const SizedBox.shrink(),
                    items: _proDurations
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(l10n.tapChallengeDurationSeconds(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _durationSeconds = v);
                    },
                  )
                else
                  GestureDetector(
                    onTap: () => showProDialog(
                      context,
                      title: l10n.tapChallengeDurationProTitle,
                      message: l10n.tapChallengeDurationProMessage,
                      generatorType: GeneratorType.tapChallenge,
                    ),
                    child: Row(
                      children: [
                        Text(
                          l10n.tapChallengeDurationSeconds(_durationSeconds),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_outline, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Haptics controls
        Card(
          child: Column(
            children: [
              SwitchListTile(
                dense: true,
                title: Text(l10n.tapChallengeVibrateOnGo),
                value: _vibrateOnGo,
                onChanged: (v) => setState(() => _vibrateOnGo = v),
              ),
              SwitchListTile(
                dense: true,
                title: Text(l10n.tapChallengeVibrateOnEnd),
                value: _vibrateOnEnd,
                onChanged: (v) => setState(() => _vibrateOnEnd = v),
              ),
            ],
          ),
        ),

        if (!gate.isPro) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.proCard(),
            child: Text(
              l10n.tapChallengeFreeProHint,
              style: AppStyles.resultStyle,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButtons(AppLocalizations l10n, Color accent) {
    if (_phase == _Phase.idle) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: AppStyles.generatorButton(accent),
          onPressed: _startCountdown,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.tapChallengeStart),
        ),
      );
    }

    if (_phase == _Phase.result) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: AppStyles.generatorButton(accent),
          onPressed: _startCountdown,
          icon: const Icon(Icons.replay),
          label: Text(l10n.tapChallengeAgain),
        ),
      );
    }

    if (_phase == _Phase.countdown || _phase == _Phase.running) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _reset,
          child: const Text('Reset'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool highlight;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.accent,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: highlight ? Colors.amber : null,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
