import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';
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

// 6 visually distinct, strongly saturated colors (same palette as memory flash)
const _kGameColors = [
  _GameColor('RED', Color(0xFFE53935)),
  _GameColor('GREEN', Color(0xFF43A047)),
  _GameColor('BLUE', Color(0xFF1E88E5)),
  _GameColor('YELLOW', Color(0xFFF9A825)),
  _GameColor('ORANGE', Color(0xFFFF6D00)),
  _GameColor('PURPLE', Color(0xFF8E24AA)),
];

const _kFreeDuration = 30;
const _kProDurations = [15, 30, 60];

// ---------------------------------------------------------------------------
// State machine
// ---------------------------------------------------------------------------

enum _Phase { idle, countdown, playing, result }

enum _AnswerMode { color, word }

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
  _AnswerMode _answerMode = _AnswerMode.color;

  // Countdown state
  int _countdownValue = 3;
  Timer? _countdownTimer;

  // Playing state
  int _timeLeft = 0;
  Timer? _gameTimer;

  int _correct = 0;
  int _wrong = 0;

  // Current challenge
  late _GameColor _wordColor; // which word to display
  late _GameColor _textColor; // actual text color
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

  int _roundsPlayed = 0;

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

  void _startCountdown() {
    if (!_checkRoundLimit()) return;
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
    const activeColors = _kGameColors;
    int wordIdx;
    int colorIdx;

    // Pick a pair that differs and doesn't immediately repeat
    do {
      wordIdx = _rng.nextInt(activeColors.length);
      colorIdx = _rng.nextInt(activeColors.length);
    } while (wordIdx == colorIdx ||
        (_lastPair != null &&
            _lastPair!.wordIdx == wordIdx &&
            _lastPair!.colorIdx == colorIdx));

    _lastPair = (wordIdx: wordIdx, colorIdx: colorIdx);
    _wordColor = activeColors[wordIdx];
    _textColor = activeColors[colorIdx];

    // Correct index depends on answer mode:
    // - color mode: tap button whose color == _textColor → colorIdx
    // - word mode: tap button whose word == _wordColor.word → wordIdx
    final correctIdx =
        _answerMode == _AnswerMode.word ? wordIdx : colorIdx;
    final others = List.generate(activeColors.length, (i) => i)
      ..remove(correctIdx)
      ..shuffle(_rng);
    final choiceIndices = [correctIdx, others[0], others[1], others[2]]
      ..shuffle(_rng);
    _choices = choiceIndices.map((i) => activeColors[i]).toList();

    _questionStart = DateTime.now();
  }

  void _onChoice(_GameColor choice) {
    if (_phase != _Phase.playing) return;

    final reactionMs =
        DateTime.now().difference(_questionStart!).inMilliseconds;

    final isCorrect = _answerMode == _AnswerMode.color
        ? choice.color == _textColor.color
        : choice.word == _wordColor.word;
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

    final historyStore = context.read<HistoryStore>();
    await historyStore.add(
      type: GeneratorType.colorReflex,
      value: '$_correct/${_correct + _wrong} (${accuracy.toStringAsFixed(1)}%)',
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

  void _onDurationTap(int seconds) {
    final gate = context.gateRead;
    if (seconds != _kFreeDuration &&
        !gate.canUse(ProFeature.colorReflexDuration)) {
      final l10n = context.l10n;
      showProDialog(
        context,
        title: l10n.colorReflexDurationProTitle,
        message: l10n.colorReflexDurationProMessage,
        generatorType: GeneratorType.colorReflex,
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
          _Phase.idle => _buildIdle(l10n, gate, accent),
          _Phase.countdown => _buildCountdown(accent),
          _Phase.playing => _buildPlaying(l10n, accent),
          _Phase.result => _buildResult(l10n, accent),
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Idle screen
  // -------------------------------------------------------------------------

  Widget _buildIdle(dynamic l10n, FeatureGate gate, Color accent) {
    final canChangeDuration = gate.canUse(ProFeature.colorReflexDuration);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Big title card ───────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: AppStyles.generatorResultCard(accent),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.generatorColorReflex,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.colorReflexDescription,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Bottom controls (sticky) ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Answer Mode
              GeneratorSectionTitle('Answer Mode'),
              const SizedBox(height: 8),
              SegmentedButton<_AnswerMode>(
                segments: const [
                  ButtonSegment(value: _AnswerMode.word, label: Text('Word')),
                  ButtonSegment(
                    value: _AnswerMode.color,
                    label: Text('Color'),
                  ),
                ],
                selected: {_answerMode},
                onSelectionChanged: (s) =>
                    setState(() => _answerMode = s.first),
              ),

              const SizedBox(height: 12),

              // Duration selector
              Row(
                children: [
                  GeneratorSectionTitle(l10n.colorReflexDurationLabel),
                  if (!canChangeDuration) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                children: _kProDurations.asMap().entries.map((e) {
                  final i = e.key;
                  final s = e.value;
                  final selected = _durationSeconds == s;
                  final isLocked = s != _kFreeDuration && !canChangeDuration;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < _kProDurations.length - 1 ? 8 : 0,
                      ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: selected
                              ? accent
                              : (isLocked ? AppColors.proPurple : null),
                          side: BorderSide(
                            color: selected
                                ? accent
                                : (isLocked
                                      ? AppColors.proPurple.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.4)),
                            width: selected ? 2 : 1,
                          ),
                          backgroundColor:
                              selected ? accent.withOpacity(0.1) : null,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _onDurationTap(s),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLocked) ...[
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: AppColors.proPurple,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text('${s}s', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                style: AppStyles.generatorButton(accent),
                onPressed: _startCountdown,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ],
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

  Widget _buildPlaying(dynamic l10n, Color accent) {
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

          // Stroop word card – no colored background
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _showWrong
                    ? Colors.red.withOpacity(0.12)
                    : Colors.transparent,
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
            _answerMode == _AnswerMode.color
                ? l10n.colorReflexTapPrompt
                : 'Tap the WORD shown above',
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
            children: _choices
                .map((c) => _ColorButton(gameColor: c, onTap: () => _onChoice(c)))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _reset,
              child: Text(l10n.commonCancel),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Result screen
  // -------------------------------------------------------------------------

  Widget _buildResult(dynamic l10n, Color accent) {
    final total = _correct + _wrong;
    final accuracy = total > 0 ? (_correct / total * 100) : 0.0;
    final avgMs =
        _reactionCount > 0 ? _totalReactionMs ~/ _reactionCount : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Scrollable stats area ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // Main result card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: AppStyles.generatorResultCard(accent),
                  child: Column(
                    children: [
                      Icon(
                        GeneratorType.colorReflex.homeIcon,
                        color: accent,
                        size: 36,
                      ),
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
              ],
            ),
          ),
        ),

        // ── Sticky bottom buttons ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: AppStyles.generatorButton(accent),
                onPressed: _startCountdown,
                icon: const Icon(Icons.replay),
                label: Text(l10n.colorReflexPlayAgain),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _reset,
                child: Text(l10n.colorReflexBackToMenu),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

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
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
