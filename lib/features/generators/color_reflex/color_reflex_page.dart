import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/l10n/app_localizations.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';

// ---------------------------------------------------------------------------
// Game data
// ---------------------------------------------------------------------------

class _GameColor {
  final String word;
  final Color color;
  const _GameColor(this.word, this.color);
}

const _kGameColors = [
  _GameColor('RED', Colors.red),
  _GameColor('GREEN', Colors.green),
  _GameColor('BLUE', Colors.blue),
  _GameColor('YELLOW', Color(0xFFF9A825)),
  _GameColor('PURPLE', Colors.purple),
  _GameColor('ORANGE', Colors.orange),
];

const _kFreeDuration = 30;
const _kProDurations = [15, 30, 60];

// ---------------------------------------------------------------------------
// State machine
// ---------------------------------------------------------------------------

enum _Phase { idle, countdown, playing, result }

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class ColorReflexPage extends StatefulWidget {
  const ColorReflexPage({super.key});

  @override
  State<ColorReflexPage> createState() => _ColorReflexPageState();
}

class _ColorReflexPageState extends State<ColorReflexPage> {
  final _rng = Random();

  _Phase _phase = _Phase.idle;

  // Settings
  int _durationSeconds = _kFreeDuration;

  // Countdown state
  int _countdownValue = 3;
  Timer? _countdownTimer;

  // Playing state
  int _timeLeft = 0;
  Timer? _gameTimer;

  int _correct = 0;
  int _wrong = 0;

  // Current challenge
  late _GameColor _wordColor;   // which word to display
  late _GameColor _textColor;   // actual text color (the correct answer)
  late List<_GameColor> _choices; // 4 shuffled buttons

  // Reaction-time tracking
  DateTime? _questionStart;
  int _totalReactionMs = 0;
  int _reactionCount = 0;

  // Avoid immediate repeat
  ({int wordIdx, int colorIdx})? _lastPair;

  // Brief wrong-answer flash
  bool _showWrong = false;
  Timer? _wrongTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    _wrongTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Game flow
  // -------------------------------------------------------------------------

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _phase = _Phase.countdown;
      _countdownValue = 3;
      _correct = 0;
      _wrong = 0;
      _totalReactionMs = 0;
      _reactionCount = 0;
      _lastPair = null;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdownValue <= 1) {
        t.cancel();
        _beginPlaying();
      } else {
        setState(() => _countdownValue--);
      }
    });
  }

  void _beginPlaying() {
    _generateChallenge();
    setState(() {
      _phase = _Phase.playing;
      _timeLeft = _durationSeconds;
    });
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timeLeft <= 1) {
        t.cancel();
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _generateChallenge() {
    int wordIdx;
    int colorIdx;

    // Pick a pair that differs and doesn't immediately repeat
    do {
      wordIdx = _rng.nextInt(_kGameColors.length);
      colorIdx = _rng.nextInt(_kGameColors.length);
    } while (wordIdx == colorIdx ||
        (_lastPair != null &&
            _lastPair!.wordIdx == wordIdx &&
            _lastPair!.colorIdx == colorIdx));

    _lastPair = (wordIdx: wordIdx, colorIdx: colorIdx);
    _wordColor = _kGameColors[wordIdx];
    _textColor = _kGameColors[colorIdx];

    // Build 4 choices: correct + 3 random others (uniform distribution)
    final others = List.generate(_kGameColors.length, (i) => i)
      ..remove(colorIdx)
      ..shuffle(_rng);
    final choiceIndices = [colorIdx, others[0], others[1], others[2]]
      ..shuffle(_rng);
    _choices = choiceIndices.map((i) => _kGameColors[i]).toList();

    _questionStart = DateTime.now();
  }

  void _onChoice(_GameColor choice) {
    if (_phase != _Phase.playing) return;

    final reactionMs =
        DateTime.now().difference(_questionStart!).inMilliseconds;

    final isCorrect = choice.color == _textColor.color;
    if (isCorrect) {
      _correct++;
      _totalReactionMs += reactionMs;
      _reactionCount++;
    } else {
      _wrong++;
      _flashWrong();
    }
    _generateChallenge();
    setState(() {});
  }

  void _flashWrong() {
    _wrongTimer?.cancel();
    setState(() => _showWrong = true);
    _wrongTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _showWrong = false);
    });
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();

    final total = _correct + _wrong;
    final accuracy = total > 0 ? (_correct / total * 100) : 0.0;
    final avgReactionMs =
        _reactionCount > 0 ? _totalReactionMs ~/ _reactionCount : 0;

    setState(() => _phase = _Phase.result);

    // Store in history
    final historyStore = context.read<HistoryStore>();
    await historyStore.add(
      type: GeneratorType.colorReflex,
      value:
          '$_correct/${_correct + _wrong} (${accuracy.toStringAsFixed(1)}%)',
      maxEntries: context.gateRead.historyMax,
      metadata: {
        'totalCorrect': _correct,
        'totalWrong': _wrong,
        'durationSeconds': _durationSeconds,
        'accuracy': double.parse(accuracy.toStringAsFixed(2)),
        'avgReactionMs': avgReactionMs,
      },
    );
  }

  void _reset() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    _wrongTimer?.cancel();
    setState(() {
      _phase = _Phase.idle;
      _showWrong = false;
    });
  }

  // -------------------------------------------------------------------------
  // Duration selector (Pro-gated)
  // -------------------------------------------------------------------------

  void _onDurationTap(int seconds) {
    final gate = context.gateRead;
    if (seconds != _kFreeDuration && !gate.canUse(ProFeature.colorReflexDuration)) {
      final l10n = context.l10n;
      showProDialog(
        context,
        title: l10n.colorReflexDurationProTitle,
        message: l10n.colorReflexDurationProMessage,
        generatorType: GeneratorType.colorReflex,
        featureDefinitions: [l10n.colorReflexFreeProHint],
      );
      return;
    }
    setState(() => _durationSeconds = seconds);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gateRead;
    final accent = GeneratorType.colorReflex.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generatorColorReflex),
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
                      generatorType: GeneratorType.colorReflex,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.colorReflex,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.idle => _buildIdle(context, l10n, gate, accent),
          _Phase.countdown => _buildCountdown(accent),
          _Phase.playing => _buildPlaying(accent),
          _Phase.result => _buildResult(context, accent),
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Idle screen
  // -------------------------------------------------------------------------

  Widget _buildIdle(
    BuildContext context,
    AppLocalizations l10n,
    FeatureGate gate,
    Color accent,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions card
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 130),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: AppStyles.generatorResultCard(accent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                GeneratorType.colorReflex.homeIcon,
                color: accent,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.colorReflexInstructions,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.colorReflexDescription,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Duration selector
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.colorReflexDurationLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _kProDurations.map((s) {
                    final isSelected = _durationSeconds == s;
                    final isFree = s == _kFreeDuration;
                    final isLocked =
                        !isFree && !gate.canUse(ProFeature.colorReflexDuration);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _DurationChip(
                          seconds: s,
                          isSelected: isSelected,
                          isLocked: isLocked,
                          accent: accent,
                          onTap: () => _onDurationTap(s),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (!gate.canUse(ProFeature.colorReflexDuration)) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 14, color: AppColors.proPurple),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.colorReflexFreeProHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.proPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppStyles.generatorButton(accent),
            onPressed: _startCountdown,
            child: const Text('Start'),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Countdown screen
  // -------------------------------------------------------------------------

  Widget _buildCountdown(Color accent) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _countdownValue > 0 ? '$_countdownValue' : 'GO!',
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.colorReflexGetReady,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Playing screen
  // -------------------------------------------------------------------------

  Widget _buildPlaying(Color accent) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timer + score row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.timer_outlined,
                label: '$_timeLeft s',
                color: _timeLeft <= 5 ? Colors.red : accent,
              ),
              _InfoChip(
                icon: Icons.check_circle_outline,
                label: '$_correct',
                color: Colors.green,
              ),
              _InfoChip(
                icon: Icons.cancel_outlined,
                label: '$_wrong',
                color: Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stroop word card
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _showWrong
                    ? Colors.red.withOpacity(0.12)
                    : accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showWrong
                      ? Colors.red.withOpacity(0.5)
                      : accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _wordColor.word,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: _textColor.color,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.colorReflexTapPrompt,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // Color choice buttons (2x2 grid)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _choices.map((c) {
              return _ColorButton(
                gameColor: c,
                onTap: () => _onChoice(c),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Result screen
  // -------------------------------------------------------------------------

  Widget _buildResult(BuildContext context, Color accent) {
    final l10n = context.l10n;
    final total = _correct + _wrong;
    final accuracy = total > 0 ? (_correct / total * 100) : 0.0;
    final avgMs = _reactionCount > 0 ? _totalReactionMs ~/ _reactionCount : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.generatorResultCard(accent),
          child: Column(
            children: [
              Icon(GeneratorType.colorReflex.homeIcon, color: accent, size: 36),
              const SizedBox(height: 10),
              Text(
                l10n.colorReflexTimeUp,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_correct / $total',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ResultStatCard(
              label: l10n.colorReflexCorrectLabel,
              value: '$_correct',
              color: Colors.green,
            ),
            _ResultStatCard(
              label: l10n.colorReflexWrongLabel,
              value: '$_wrong',
              color: Colors.redAccent,
            ),
            _ResultStatCard(
              label: l10n.colorReflexAccuracyLabel,
              value: '${accuracy.toStringAsFixed(1)}%',
              color: accent,
            ),
            if (avgMs > 0)
              _ResultStatCard(
                label: l10n.colorReflexAvgReactionLabel,
                value: '$avgMs ms',
                color: Colors.orange,
              ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppStyles.generatorButton(accent),
            onPressed: _startCountdown,
            child: Text(l10n.colorReflexPlayAgain),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _reset,
            child: Text(l10n.colorReflexBackToMenu),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _DurationChip extends StatelessWidget {
  final int seconds;
  final bool isSelected;
  final bool isLocked;
  final Color accent;
  final VoidCallback onTap;

  const _DurationChip({
    required this.seconds,
    required this.isSelected,
    required this.isLocked,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.9) : accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : accent.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked) ...[
              Icon(
                Icons.lock_outline,
                size: 13,
                color: isSelected ? Colors.white : AppColors.proPurple,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '${seconds}s',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : null,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final _GameColor gameColor;
  final VoidCallback onTap;

  const _ColorButton({required this.gameColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: gameColor.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: gameColor.color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            gameColor.word,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
