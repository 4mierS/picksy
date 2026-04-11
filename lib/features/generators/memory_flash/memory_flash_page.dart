import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

enum _Phase { idle, flashing, input, correct, gameover }

enum _Speed { slow, normal, fast }

class MemoryFlashPage extends StatefulWidget {
  const MemoryFlashPage({super.key});

  @override
  State<MemoryFlashPage> createState() => _MemoryFlashPageState();
}

class _MemoryFlashPageState extends State<MemoryFlashPage> {
  static const double _maxGridWidth = 420.0;
  static const int _gridColumns = 2;
  static const double _tileSpacing = 12.0;
  static const int _freeLevelCap = 10;

  // 6 visually distinct colors: red, blue, green, yellow, orange, purple
  static const List<Color> _distinctTileColors = [
    Color(0xFFEF5350), // red
    Color(0xFF42A5F5), // blue
    Color(0xFF66BB6A), // green
    Color(0xFFFFEE58), // yellow
    Color(0xFFFFA726), // orange
    Color(0xFFAB47BC), // purple
  ];

  final _rng = Random();
  _Phase _phase = _Phase.idle;
  _Speed _speed = _Speed.normal;
  int _blockCount = 4;

  List<int> _sequence = [];
  int _inputIndex = 0;
  int _level = 0;
  int _highlightedTile = -1;
  int _totalSequences = 0;

  DateTime? _gameStart;
  Timer? _flashTimer;

  List<Color> get _activeTileColors =>
      _distinctTileColors.take(_blockCount).toList();

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
    int next;
    do {
      next = _rng.nextInt(_activeTileColors.length);
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
        setState(() {
          _highlightedTile = -1;
          _phase = _Phase.input;
        });
        return;
      }

      if (step.isEven) {
        setState(() => _highlightedTile = _sequence[step ~/ 2]);
      } else {
        setState(() => _highlightedTile = -1);
      }

      final delay = step.isEven ? _flashDurationMs : _pauseDurationMs;
      step++;
      _flashTimer = Timer(Duration(milliseconds: delay), doStep);
    }

    _flashTimer = Timer(const Duration(milliseconds: 400), doStep);
  }

  void _onTileTap(int tileIndex) {
    if (_phase != _Phase.input) return;

    if (tileIndex == _sequence[_inputIndex]) {
      _inputIndex++;
      if (_inputIndex == _sequence.length) {
        _totalSequences++;
        final gate = context.gateRead;
        final atCap = !gate.isPro && _level >= _freeLevelCap;

        if (atCap) {
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
      _saveHistory();
      setState(() => _phase = _Phase.gameover);
    }
  }

  void _saveHistory() {
    final gate = context.gateRead;
    final duration = _gameStart != null
        ? DateTime.now().difference(_gameStart!).inSeconds
        : 0;
    context.read<HistoryStore>().add(
      type: GeneratorType.memoryFlash,
      value: 'Level $_level – $_totalSequences sequences',
      maxEntries: gate.historyMax,
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
    final isSettingsEnabled =
        _phase == _Phase.idle || _phase == _Phase.gameover;

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
      body: Column(
        children: [
          // ── Status card (hidden in idle) ─────────────────────────────────
          if (_phase != _Phase.idle)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: AppStyles.generatorResultCard(accent),
                child: _buildStatus(l10n, accent),
              ),
            ),

          // ── Tile grid (Expanded — never overflows) ───────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rows =
                      (_activeTileColors.length / _gridColumns).ceil();
                  final byWidth =
                      constraints.maxWidth.clamp(0.0, _maxGridWidth) /
                          _gridColumns -
                      _tileSpacing;
                  final byHeight =
                      (constraints.maxHeight - (rows - 1) * _tileSpacing) /
                      rows;
                  final size = min(byWidth, byHeight).clamp(60.0, 200.0);
                  return Center(
                    child: Wrap(
                      spacing: _tileSpacing,
                      runSpacing: _tileSpacing,
                      alignment: WrapAlignment.center,
                      children: List.generate(_activeTileColors.length, (i) {
                        return _MemoryTile(
                          size: size,
                          color: _activeTileColors[i],
                          isHighlighted: _highlightedTile == i,
                          enabled: _phase == _Phase.input,
                          onTap: () => _onTileTap(i),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Progress bar during input ────────────────────────────────────
          if (_phase == _Phase.input && _sequence.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
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
                ],
              ),
            ),

          // ── Bottom controls (sticky) ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Blocks
                _BlockSettings(
                  blockCount: _blockCount,
                  enabled: isSettingsEnabled,
                  accent: accent,
                  onChanged: (count) => setState(() {
                    _blockCount = count;
                    _sequence.clear();
                  }),
                ),
                const SizedBox(height: 10),

                // Flash speed
                _SpeedSettings(
                  speed: _speed,
                  enabled: isSettingsEnabled,
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
                const SizedBox(height: 12),

                // Start / Play again button
                if (_phase == _Phase.idle)
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.memoryFlashStart),
                  )
                else if (_phase == _Phase.gameover)
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.memoryFlashPlayAgain),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(dynamic l10n, Color accent) {
    final String headline;
    final String? subtext;

    switch (_phase) {
      case _Phase.idle:
        headline = '';
        subtext = null;
      case _Phase.flashing:
        headline = _level > 0 ? l10n.memoryFlashLevel(_level) : '';
        subtext = l10n.memoryFlashWatchSequence;
      case _Phase.input:
        headline = l10n.memoryFlashLevel(_level);
        subtext = l10n.memoryFlashYourTurn;
      case _Phase.correct:
        headline = l10n.memoryFlashLevel(_level);
        subtext = '✓';
      case _Phase.gameover:
        headline = l10n.memoryFlashGameOver;
        subtext = l10n.memoryFlashResult(_level);
    }

    return Column(
      children: [
        if (headline.isNotEmpty)
          Text(
            headline,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
        if (subtext != null) ...[
          if (headline.isNotEmpty) const SizedBox(height: 4),
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

// ─── Block Settings ───────────────────────────────────────────────────────────

class _BlockSettings extends StatelessWidget {
  final int blockCount;
  final bool enabled;
  final Color accent;
  final void Function(int) onChanged;

  const _BlockSettings({
    required this.blockCount,
    required this.enabled,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = [3, 4, 5, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GeneratorSectionTitle(l10n.memoryFlashBlocks),
        const SizedBox(height: 8),
        Row(
          children: List.generate(counts.length, (i) {
            final count = counts[i];
            final selected = blockCount == count;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < counts.length - 1 ? 8 : 0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: selected ? accent : null,
                    side: BorderSide(
                      color: selected ? accent : Colors.grey.withOpacity(0.4),
                      width: selected ? 2 : 1,
                    ),
                    backgroundColor: selected ? accent.withOpacity(0.1) : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: enabled ? () => onChanged(count) : null,
                  child: Text('$count'),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Speed Settings ───────────────────────────────────────────────────────────

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
            GeneratorSectionTitle(l10n.memoryFlashFlashSpeed),
            if (!gate.canUse(ProFeature.memoryFlashSpeed)) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    backgroundColor: selected ? accent.withOpacity(0.1) : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: enabled ? () => onSpeedChanged(s) : null,
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

// ─── Memory Tile ──────────────────────────────────────────────────────────────

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
