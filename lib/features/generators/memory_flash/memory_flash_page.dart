import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/app_localizations.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

enum _Phase { idle, flashing, input, correct, gameover }

enum _Speed { slow, normal, fast }

class MemoryFlashPage extends StatefulWidget {
  const MemoryFlashPage({super.key});

  @override
  State<MemoryFlashPage> createState() => _MemoryFlashPageState();
}

class _MemoryFlashPageState extends State<MemoryFlashPage> {
  static const int _freeLevelCap = 10;
  static const int _historyMaxEntriesFree = 50;
  static const int _historyMaxEntriesPro = 1000;

  static const List<Color> _tileColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.amber,
  ];

  final _rng = Random();
  _Phase _phase = _Phase.idle;
  _Speed _speed = _Speed.normal;

  List<int> _sequence = [];
  int _inputIndex = 0;
  int _level = 0;
  int _highlightedTile = -1;
  int _totalSequences = 0;

  DateTime? _gameStart;

  Timer? _flashTimer;

  int get _flashDurationMs {
    switch (_speed) {
      case _Speed.slow:
        return 800;
      case _Speed.normal:
        return 500;
      case _Speed.fast:
        return 300;
    }
  }

  int get _pauseDurationMs => _flashDurationMs ~/ 2;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _flashTimer?.cancel();
    setState(() {
      _sequence = [];
      _inputIndex = 0;
      _level = 0;
      _totalSequences = 0;
      _highlightedTile = -1;
      _gameStart = DateTime.now();
      _phase = _Phase.flashing;
    });
    _advanceLevel();
  }

  void _advanceLevel() {
    _flashTimer?.cancel();
    // Add one new element (no immediate full repetition: ensure last != new)
    int next;
    do {
      next = _rng.nextInt(_tileColors.length);
    } while (_sequence.isNotEmpty && next == _sequence.last);

    setState(() {
      _sequence.add(next);
      _level = _sequence.length;
      _inputIndex = 0;
      _highlightedTile = -1;
      _phase = _Phase.flashing;
    });

    _flashSequence();
  }

  void _flashSequence() {
    int step = 0;

    void doStep() {
      if (!mounted) return;
      if (step >= _sequence.length * 2) {
        // Done flashing → input phase
        setState(() {
          _highlightedTile = -1;
          _phase = _Phase.input;
        });
        return;
      }

      if (step.isEven) {
        // Highlight tile
        setState(() => _highlightedTile = _sequence[step ~/ 2]);
      } else {
        // Turn off
        setState(() => _highlightedTile = -1);
      }

      final delay = step.isEven ? _flashDurationMs : _pauseDurationMs;
      step++;
      _flashTimer = Timer(Duration(milliseconds: delay), doStep);
    }

    // Small initial pause before starting
    _flashTimer = Timer(const Duration(milliseconds: 400), doStep);
  }

  void _onTileTap(int tileIndex) {
    if (_phase != _Phase.input) return;

    if (tileIndex == _sequence[_inputIndex]) {
      _inputIndex++;
      if (_inputIndex == _sequence.length) {
        // Correct full sequence
        _totalSequences++;
        final gate = context.gateRead;

        final isPro = gate.isPro;
        final atCap = !isPro && _level >= _freeLevelCap;

        if (atCap) {
          // Free user reached max level — game over (win)
          _saveHistory();
          setState(() => _phase = _Phase.gameover);
        } else {
          setState(() => _phase = _Phase.correct);
          _flashTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) _advanceLevel();
          });
        }
      }
    } else {
      // Wrong tap
      _saveHistory();
      setState(() => _phase = _Phase.gameover);
    }
  }

  void _saveHistory() {
    final history = context.read<HistoryStore>();
    final gate = context.gateRead;
    final duration =
        _gameStart != null
            ? DateTime.now().difference(_gameStart!).inSeconds
            : 0;

    history.add(
      type: GeneratorType.memoryFlash,
      value: 'Level $_level – $_totalSequences sequences',
      maxEntries:
          gate.isPro ? _historyMaxEntriesPro : _historyMaxEntriesFree,
      metadata: {
        'maxLevel': _level,
        'totalSequences': _totalSequences,
        'durationSeconds': duration,
        'speedSetting': _speed.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gateRead;
    final accent = GeneratorType.memoryFlash.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memoryFlashTitle),
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
                      generatorType: GeneratorType.memoryFlash,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.memoryFlash,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: AppStyles.generatorResultCard(accent),
                child: _StatusSection(
                  phase: _phase,
                  level: _level,
                  totalSequences: _totalSequences,
                  l10n: context.l10n,
                ),
              ),

              const SizedBox(height: 20),

              // Tile grid
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = (constraints.maxWidth.clamp(0.0, 320.0)) /
                          2 -
                          12;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: List.generate(_tileColors.length, (i) {
                          final isHighlighted = _highlightedTile == i;
                          return _MemoryTile(
                            size: size,
                            color: _tileColors[i],
                            isHighlighted: isHighlighted,
                            enabled: _phase == _Phase.input,
                            onTap: () => _onTileTap(i),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress indicator during input phase
              if (_phase == _Phase.input && _sequence.isNotEmpty) ...[
                Text(
                  l10n.memoryFlashSequenceLength(_sequence.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: _inputIndex / _sequence.length,
                  color: accent,
                  backgroundColor: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              if (_phase == _Phase.idle) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    child: Text(l10n.memoryFlashStart),
                  ),
                ),
              ],

              if (_phase == _Phase.gameover) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    child: Text(l10n.memoryFlashPlayAgain),
                  ),
                ),
              ],

              // Settings card
              const SizedBox(height: 8),
              Card(
                child: ExpansionTile(
                  title: Text(l10n.hangmanSettings),
                  leading: const Icon(Icons.tune),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _SpeedSettings(
                        speed: _speed,
                        enabled: _phase == _Phase.idle ||
                            _phase == _Phase.gameover,
                        gate: gate,
                        onSpeedChanged: (s) {
                          if (!gate.canUse(ProFeature.memoryFlashSpeed)) {
                            showProDialog(
                              context,
                              title: l10n.memoryFlashProSpeedTitle,
                              message: l10n.memoryFlashProSpeedMessage,
                              generatorType: GeneratorType.memoryFlash,
                            );
                            return;
                          }
                          setState(() => _speed = s);
                        },
                      ),
                    ),
                    if (!gate.isPro)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          l10n.memoryFlashFreeProHint,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.proPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status Section ──────────────────────────────────────────────────────────

class _StatusSection extends StatelessWidget {
  final _Phase phase;
  final int level;
  final int totalSequences;
  final AppLocalizations l10n;

  const _StatusSection({
    required this.phase,
    required this.level,
    required this.totalSequences,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final String headline;
    final String? subtext;

    switch (phase) {
      case _Phase.idle:
        headline = l10n.memoryFlashTitle;
        subtext = null;
        break;
      case _Phase.flashing:
        headline = level > 0 ? l10n.memoryFlashLevel(level) : '';
        subtext = l10n.memoryFlashWatchSequence;
        break;
      case _Phase.input:
        headline = l10n.memoryFlashLevel(level);
        subtext = l10n.memoryFlashYourTurn;
        break;
      case _Phase.correct:
        headline = l10n.memoryFlashLevel(level);
        subtext = '✓';
        break;
      case _Phase.gameover:
        headline = l10n.memoryFlashGameOver;
        subtext = l10n.memoryFlashResult(level);
        break;
    }

    return Column(
      children: [
        Text(
          headline,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        if (subtext != null) ...[
          const SizedBox(height: 6),
          Text(
            subtext,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─── Memory Tile ─────────────────────────────────────────────────────────────

class _MemoryTile extends StatelessWidget {
  final double size;
  final Color color;
  final bool isHighlighted;
  final bool enabled;
  final VoidCallback onTap;

  const _MemoryTile({
    required this.size,
    required this.color,
    required this.isHighlighted,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isHighlighted ? color : color.withOpacity(0.25),
        border: Border.all(
          color: isHighlighted ? color : color.withOpacity(0.4),
          width: isHighlighted ? 3 : 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.55),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          splashColor: color.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Speed Settings ──────────────────────────────────────────────────────────

class _SpeedSettings extends StatelessWidget {
  final _Speed speed;
  final bool enabled;
  final FeatureGate gate;
  final void Function(_Speed) onSpeedChanged;

  const _SpeedSettings({
    required this.speed,
    required this.enabled,
    required this.gate,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = GeneratorType.memoryFlash.accentColor;
    final speeds = [_Speed.slow, _Speed.normal, _Speed.fast];
    final labels = [
      l10n.memoryFlashSpeedSlow,
      l10n.memoryFlashSpeedNormal,
      l10n.memoryFlashSpeedFast,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.memoryFlashFlashSpeed,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (!gate.canUse(ProFeature.memoryFlashSpeed)) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.proPurple.withOpacity(0.15),
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
          children: List.generate(speeds.length, (i) {
            final s = speeds[i];
            final selected = speed == s;
            final canChange =
                enabled && gate.canUse(ProFeature.memoryFlashSpeed);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < speeds.length - 1 ? 8 : 0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: selected ? accent : null,
                    side: BorderSide(
                      color: selected ? accent : Colors.grey.withOpacity(0.4),
                      width: selected ? 2 : 1,
                    ),
                    backgroundColor:
                        selected ? accent.withOpacity(0.1) : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: (canChange || !gate.canUse(ProFeature.memoryFlashSpeed))
                      ? () => onSpeedChanged(s)
                      : null,
                  child: Text(labels[i], style: const TextStyle(fontSize: 13)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
