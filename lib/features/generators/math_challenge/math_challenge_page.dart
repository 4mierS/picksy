import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

enum _Difficulty { easy, hard }

enum _Phase { idle, countdown, playing, result }

class _MathProblem {
  final int a;
  final int b;
  final String operator;
  final int answer;
  final List<int> options;

  const _MathProblem({
    required this.a,
    required this.b,
    required this.operator,
    required this.answer,
    required this.options,
  });
}

class MathChallengePage extends StatefulWidget {
  const MathChallengePage({super.key});

  @override
  State<MathChallengePage> createState() => _MathChallengePageState();
}

class _MathChallengePageState extends State<MathChallengePage> {
  final _rng = Random();

  _Phase _phase = _Phase.idle;
  _Difficulty _difficulty = _Difficulty.easy;
  int _durationSeconds = 30;

  int _countdown = 3;
  Timer? _countdownTimer;
  Timer? _gameTimer;
  int _timeLeft = 30;

  _MathProblem? _current;
  int _correct = 0;
  int _wrong = 0;
  int? _selectedOption;

  static const int _historyMaxEntries = 100;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _phase = _Phase.countdown;
      _countdown = 3;
      _correct = 0;
      _wrong = 0;
      _current = null;
      _selectedOption = null;
      _timeLeft = _durationSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        _startGame();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _startGame() {
    setState(() {
      _phase = _Phase.playing;
      _timeLeft = _durationSeconds;
    });
    _nextProblem();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _nextProblem() {
    setState(() {
      _current = _generateProblem();
      _selectedOption = null;
    });
  }

  _MathProblem _generateProblem() {
    final ops = _difficulty == _Difficulty.easy ? ['+', '-'] : ['+', '-', '×', '÷'];
    final op = ops[_rng.nextInt(ops.length)];

    int a, b, answer;

    if (_difficulty == _Difficulty.easy) {
      a = 1 + _rng.nextInt(20);
      b = 1 + _rng.nextInt(20);
      if (op == '+') {
        answer = a + b;
      } else {
        if (a < b) {
          final tmp = a;
          a = b;
          b = tmp;
        }
        answer = a - b;
      }
    } else {
      if (op == '+' || op == '-') {
        a = 10 + _rng.nextInt(91);
        b = 10 + _rng.nextInt(91);
        if (op == '+') {
          answer = a + b;
        } else {
          if (a < b) {
            final tmp = a;
            a = b;
            b = tmp;
          }
          answer = a - b;
        }
      } else if (op == '×') {
        a = 2 + _rng.nextInt(12);
        b = 2 + _rng.nextInt(12);
        answer = a * b;
      } else {
        // Division: generate integer result first, then derive dividend
        answer = 1 + _rng.nextInt(12);
        b = 2 + _rng.nextInt(12);
        a = answer * b;
      }
    }

    // Generate 3 distinct wrong options
    final wrongs = <int>{};
    while (wrongs.length < 3) {
      final offset = _rng.nextInt(11) - 5;
      final wrong = answer + (offset == 0 ? 1 : offset);
      if (wrong != answer && wrong >= 0) wrongs.add(wrong);
    }

    final options = [answer, ...wrongs]..shuffle(_rng);
    return _MathProblem(a: a, b: b, operator: op, answer: answer, options: options);
  }

  void _onAnswer(int chosen) {
    if (_selectedOption != null) return;
    final isCorrect = chosen == _current!.answer;
    setState(() {
      _selectedOption = chosen;
      if (isCorrect) {
        _correct++;
      } else {
        _wrong++;
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _phase == _Phase.playing) _nextProblem();
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() => _phase = _Phase.result);

    final total = _correct + _wrong;
    final accuracy = total > 0 ? (_correct / total * 100).round() : 0;
    final diffStr = _difficulty == _Difficulty.easy ? 'easy' : 'hard';

    context.read<HistoryStore>().add(
      type: GeneratorType.mathChallenge,
      value: '$_correct correct, $_wrong wrong (${accuracy}%)',
      maxEntries: _historyMaxEntries,
      metadata: {
        'correctCount': _correct,
        'wrongCount': _wrong,
        'durationSeconds': _durationSeconds,
        'difficulty': diffStr,
        'accuracy': accuracy,
      },
    );
  }

  double get _accuracyPercent {
    final total = _correct + _wrong;
    if (total == 0) return 0.0;
    return _correct / total * 100;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.mathChallenge.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generatorMathChallenge),
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
                      generatorType: GeneratorType.mathChallenge,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.mathChallenge,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (_phase) {
            _Phase.idle => _buildIdle(context, l10n, gate, accent),
            _Phase.countdown => _buildCountdown(accent),
            _Phase.playing => _buildPlaying(context, l10n, accent),
            _Phase.result => _buildResult(context, l10n, accent),
          },
        ),
      ),
    );
  }

  Widget _buildIdle(
    BuildContext context,
    dynamic l10n,
    FeatureGate gate,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Difficulty selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mathDifficulty,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.mathDifficultyEasy)),
                        selected: _difficulty == _Difficulty.easy,
                        onSelected: (_) => setState(() => _difficulty = _Difficulty.easy),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.mathDifficultyHard)),
                        selected: _difficulty == _Difficulty.hard,
                        onSelected: (_) {
                          if (!gate.canUse(ProFeature.mathChallengeProDifficulty)) {
                            showProDialog(
                              context,
                              title: l10n.mathDifficultyProTitle,
                              message: l10n.mathDifficultyProMessage,
                              generatorType: GeneratorType.mathChallenge,
                            );
                          } else {
                            setState(() => _difficulty = _Difficulty.hard);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Duration selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mathDuration,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),
                if (gate.canUse(ProFeature.mathChallengeProDuration)) ...[
                  Text(l10n.mathDurationSeconds(_durationSeconds)),
                  Slider(
                    min: 15,
                    max: 60,
                    divisions: 9,
                    value: _durationSeconds.toDouble(),
                    onChanged: (v) => setState(() => _durationSeconds = v.round()),
                    activeColor: accent,
                  ),
                ] else
                  Row(
                    children: [
                      Text(l10n.mathDurationFree),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.lock_outline, size: 16),
                        label: Text(l10n.commonProFeature),
                        onPressed: () => showProDialog(
                          context,
                          title: l10n.mathDurationProTitle,
                          message: l10n.mathDurationProMessage,
                          generatorType: GeneratorType.mathChallenge,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Pro hint
        if (!gate.canUse(ProFeature.mathChallengeProDifficulty))
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.mathFreeProHint,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppStyles.generatorButton(accent),
            onPressed: _startCountdown,
            child: Text(l10n.mathStart),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(Color accent) {
    return Center(
      child: Text(
        '$_countdown',
        style: TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: accent),
      ),
    );
  }

  Widget _buildPlaying(BuildContext context, dynamic l10n, Color accent) {
    final p = _current;
    if (p == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats row
        Row(
          children: [
            _StatChip(
              label: l10n.mathTimeLeft,
              value: '$_timeLeft s',
              color: _timeLeft <= 5 ? Colors.red : accent,
            ),
            const SizedBox(width: 8),
            _StatChip(label: l10n.mathCorrect, value: '$_correct', color: Colors.green),
            const SizedBox(width: 8),
            _StatChip(label: l10n.mathWrong, value: '$_wrong', color: Colors.red),
          ],
        ),

        const SizedBox(height: 20),

        // Problem display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          decoration: AppStyles.generatorResultCard(accent),
          child: Text(
            '${p.a} ${p.operator} ${p.b} = ?',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // Answer options 2×2 grid
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          physics: const NeverScrollableScrollPhysics(),
          children: p.options.map((opt) {
            Color? bgColor;
            if (_selectedOption != null) {
              if (opt == p.answer) {
                bgColor = Colors.green.shade400;
              } else if (opt == _selectedOption) {
                bgColor = Colors.red.shade400;
              }
            }
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              onPressed: _selectedOption == null ? () => _onAnswer(opt) : null,
              child: Text('$opt'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, dynamic l10n, Color accent) {
    final accuracy = _accuracyPercent.toStringAsFixed(1);
    final pps = (_correct / _durationSeconds).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.generatorResultCard(accent),
          child: Column(
            children: [
              Text(
                l10n.mathResultTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ResultStat(label: l10n.mathCorrect, value: '$_correct', color: Colors.green),
                  _ResultStat(label: l10n.mathWrong, value: '$_wrong', color: Colors.red),
                  _ResultStat(label: l10n.mathAccuracy, value: '$accuracy%', color: accent),
                  _ResultStat(label: l10n.mathPPS, value: pps, color: Colors.blueAccent),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppStyles.generatorButton(accent),
            onPressed: _startCountdown,
            child: Text(l10n.mathPlayAgain),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _phase = _Phase.idle),
            child: Text(l10n.mathBackToMenu),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16),
            ),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
