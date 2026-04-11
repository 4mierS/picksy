import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';

import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

enum _Phase { idle, countdown, running, result }

class TapChallengePage extends StatefulWidget {
  const TapChallengePage({super.key});

  @override
  State<TapChallengePage> createState() => _TapChallengePageState();
}

class _TapChallengePageState extends State<TapChallengePage> {
  _Phase _phase = _Phase.idle;

  int _countdownValue = 3;
  Timer? _countdownTimer;

  int _tapsCount = 0;
  int _durationSeconds = 5;
  int _remainingMs = 0;
  Timer? _runTimer;
  Timer? _tickTimer;
  DateTime? _runStart;

  int? _lastTaps;
  double? _lastTPS;
  int? _personalBest;
  int _roundsPlayed = 0;

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

  bool _checkRoundLimit() {
    if (context.gateRead.isPro) return true;
    if (_roundsPlayed >= FeatureGate.freeRoundsMax) {
      final l10n = context.l10n;
      showProDialog(context,
          title: l10n.homeDailyLimitTitle, message: l10n.homeDailyLimitMessage);
      return false;
    }
    _roundsPlayed++;
    return true;
  }

  Future<void> _startCountdown() async {
    if (!_checkRoundLimit()) return;
    _countdownTimer?.cancel();
    _runTimer?.cancel();
    _tickTimer?.cancel();
    setState(() {
      _phase = _Phase.countdown;
      _countdownValue = 3;
      _tapsCount = 0;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
      } else if (_countdownValue == 1) {
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

    final hasV = await Vibration.hasVibrator();
    if (hasV ?? false) Vibration.vibrate(duration: 100);

    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) { t.cancel(); return; }
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

    context.read<HistoryStore>().add(
      type: GeneratorType.tapChallenge,
      value: '$taps taps',
      maxEntries: context.gateRead.historyMax,
      metadata: {
        'tapsCount': taps,
        'durationSeconds': _durationSeconds,
        'tapsPerSecond': double.parse(tps.toStringAsFixed(2)),
      },
    );

    final hasV = await Vibration.hasVibrator();
    if (hasV ?? false) Vibration.vibrate(duration: 300);
  }

  void _onTap() {
    if (_phase == _Phase.running) {
      setState(() => _tapsCount++);
    }
  }

  Color _bgColor(BuildContext context) {
    if (_phase == _Phase.running) {
      return GeneratorType.tapChallenge.accentColor.withValues(alpha: 0.12);
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.tapChallenge.accentColor;
    final isSettingsEnabled = _phase == _Phase.idle || _phase == _Phase.result;

    return Scaffold(
      backgroundColor: _bgColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Main card (Expanded, centered) ────────────────────────────
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    decoration: AppStyles.generatorResultCard(accent),
                    child: _buildCardContent(l10n, accent),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Duration selector (idle + result only) ────────────────────
              if (isSettingsEnabled) ...[
                _DurationSelector(
                  accent: accent,
                  durationSeconds: _durationSeconds,
                  gate: gate,
                  onChanged: (v) => setState(() => _durationSeconds = v),
                  onLockedTap: () => showProDialog(
                    context,
                    title: l10n.tapChallengeDurationProTitle,
                    message: l10n.tapChallengeDurationProMessage,
                    generatorType: GeneratorType.tapChallenge,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Buttons ───────────────────────────────────────────────────
              if (_phase == _Phase.idle)
                FilledButton.icon(
                  style: AppStyles.generatorButton(accent),
                  onPressed: _startCountdown,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.tapChallengeStart),
                )
              else if (_phase == _Phase.result)
                FilledButton.icon(
                  style: AppStyles.generatorButton(accent),
                  onPressed: _startCountdown,
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.tapChallengeAgain),
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _reset,
                  child: Text(l10n.timeReset),
                ),

              // ── Tip ───────────────────────────────────────────────────────
              const SizedBox(height: 10),
              Text(
                l10n.tapChallengeInstructions,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(dynamic l10n, Color accent) {
    switch (_phase) {
      case _Phase.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.tapChallengeTitle,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapChallengeGetReady,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Phase.countdown:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _countdownValue > 0 ? '$_countdownValue' : l10n.tapChallengeGo,
              style: TextStyle(
                fontSize: 80,
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
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.tapChallengeTaps,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _remainingMs / (_durationSeconds * 1000),
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.2),
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
            const SizedBox(height: 20),
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
}

// ─── Duration Selector ────────────────────────────────────────────────────────

class _DurationSelector extends StatelessWidget {
  final Color accent;
  final int durationSeconds;
  final FeatureGate gate;
  final void Function(int) onChanged;
  final VoidCallback onLockedTap;

  const _DurationSelector({
    required this.accent,
    required this.durationSeconds,
    required this.gate,
    required this.onChanged,
    required this.onLockedTap,
  });

  static const _durations = [5, 10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canChange = gate.canUse(ProFeature.tapChallengeDuration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GeneratorSectionTitle(l10n.tapChallengeDurationLabel),
            if (!canChange) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.proPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.proPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_durations.length, (i) {
            final s = _durations[i];
            final selected = durationSeconds == s;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _durations.length - 1 ? 6 : 0),
                child: GestureDetector(
                  onTap: canChange ? null : onLockedTap,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: selected ? accent : null,
                      side: BorderSide(
                        color: selected ? accent : Colors.grey.withValues(alpha: 0.4),
                        width: selected ? 2 : 1,
                      ),
                      backgroundColor: selected ? accent.withValues(alpha: 0.1) : null,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: canChange ? () => onChanged(s) : null,
                    child: Text(
                      l10n.tapChallengeDurationSeconds(s),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Result Stat ──────────────────────────────────────────────────────────────

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
