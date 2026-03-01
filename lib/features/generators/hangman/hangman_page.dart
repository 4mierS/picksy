import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';

enum _HangmanPhase { idle, playing, won, lost }

class HangmanPage extends StatefulWidget {
  const HangmanPage({super.key});

  @override
  State<HangmanPage> createState() => _HangmanPageState();
}

class _HangmanPageState extends State<HangmanPage> {
  final _rng = Random();

  _HangmanPhase _phase = _HangmanPhase.idle;
  String _word = '';
  final Set<String> _guessed = {};
  int _wrongGuesses = 0;

  static const int _maxWrongGuesses = 6;

  // Settings
  int _minLength = 4;
  int _maxLength = 8;

  static const int _historyMaxEntries = 100;

  static const List<String> _wordList = [
    'apple', 'banana', 'cherry', 'dragon', 'eagle',
    'forest', 'guitar', 'harbor', 'island', 'jungle',
    'kettle', 'lemon', 'mango', 'nature', 'orange',
    'panda', 'queen', 'river', 'sunset', 'tiger',
    'umbrella', 'violet', 'walrus', 'xenon', 'yellow',
    'zebra', 'anchor', 'bridge', 'candle', 'desert',
    'engine', 'flower', 'garden', 'hammer', 'igloo',
    'jacket', 'kitten', 'lantern', 'mirror', 'needle',
    'otter', 'pepper', 'quartz', 'rocket', 'saddle',
    'turtle', 'upward', 'vendor', 'winter', 'xylem',
    'yogurt', 'zipper', 'almond', 'button', 'cactus',
    'dagger', 'elbow', 'falcon', 'goblin', 'hunter',
    'insect', 'jigsaw', 'kernel', 'locket', 'marble',
    'napkin', 'oyster', 'pirate', 'rabbit', 'salmon',
    'switch', 'teapot', 'unfold', 'valley', 'walnut',
    'branch', 'castle', 'donkey', 'empire', 'feather',
    'goblet', 'helmet', 'invent', 'jewel', 'knight',
    'ladder', 'magnet', 'nimble', 'onion', 'puzzle',
    'quiver', 'riddle', 'shield', 'throne', 'utopia',
    'vessel', 'wander', 'parrot', 'basket', 'canopy',
  ];

  void _startGame() {
    final filtered = _wordList
        .where((w) => w.length >= _minLength && w.length <= _maxLength)
        .toList();
    if (filtered.isEmpty) return;

    setState(() {
      _word = filtered[_rng.nextInt(filtered.length)].toUpperCase();
      _guessed.clear();
      _wrongGuesses = 0;
      _phase = _HangmanPhase.playing;
    });
  }

  void _guessLetter(String letter) {
    if (_guessed.contains(letter) || _phase != _HangmanPhase.playing) return;

    String? historyValue;

    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) {
        _wrongGuesses++;
        if (_wrongGuesses >= _maxWrongGuesses) {
          _phase = _HangmanPhase.lost;
          historyValue = 'Lost – $_word';
        }
      } else {
        final allRevealed = _word.split('').every(_guessed.contains);
        if (allRevealed) {
          _phase = _HangmanPhase.won;
          historyValue = 'Won – $_word';
        }
      }
    });

    if (historyValue != null) {
      _saveHistory(historyValue!);
    }
  }

  void _saveHistory(String value) {
    final history = context.read<HistoryStore>();
    history.add(
      type: GeneratorType.hangman,
      value: value,
      maxEntries: _historyMaxEntries,
    );
  }

  List<String> get _wrongLetters =>
      _guessed.where((l) => !_word.contains(l)).toList()..sort();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = GeneratorType.hangman.accentColor;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hangmanTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hangman drawing
              Container(
                height: 200,
                decoration: AppStyles.generatorResultCard(accent),
                child: CustomPaint(
                  painter: _HangmanPainter(
                    wrongGuesses: _wrongGuesses,
                    accent: accent,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_phase == _HangmanPhase.idle) ...[
                Text(
                  l10n.hangmanGuessWord,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    child: Text(l10n.hangmanNewGame),
                  ),
                ),
              ],

              if (_phase == _HangmanPhase.playing ||
                  _phase == _HangmanPhase.won ||
                  _phase == _HangmanPhase.lost) ...[
                // Word display
                _WordDisplay(word: _word, guessed: _guessed, accent: accent),
                const SizedBox(height: 12),

                // Attempts left
                if (_phase == _HangmanPhase.playing) ...[
                  Text(
                    l10n.hangmanAttemptsLeft(_maxWrongGuesses - _wrongGuesses),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],

                // Wrong letters
                if (_wrongLetters.isNotEmpty) ...[
                  Text(
                    '${l10n.hangmanWrongLetters} ${_wrongLetters.join(' ')}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Win / Loss message
                if (_phase == _HangmanPhase.won) ...[
                  Text(
                    l10n.hangmanYouWon,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_phase == _HangmanPhase.lost) ...[
                  Text(
                    l10n.hangmanYouLost(_word),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Keyboard
                if (_phase == _HangmanPhase.playing)
                  _LetterKeyboard(
                    guessed: _guessed,
                    word: _word,
                    accent: accent,
                    onGuess: _guessLetter,
                  ),

                if (_phase == _HangmanPhase.won ||
                    _phase == _HangmanPhase.lost) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppStyles.generatorButton(accent),
                      onPressed: _startGame,
                      child: Text(l10n.hangmanPlayAgain),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Settings card
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.hangmanMinLength}: $_minLength',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _minLength.toDouble(),
                            min: 3,
                            max: 10,
                            divisions: 7,
                            label: '$_minLength',
                            activeColor: accent,
                            onChanged: _phase == _HangmanPhase.idle
                                ? (v) => setState(() {
                                      _minLength = v.round();
                                      if (_minLength > _maxLength) {
                                        _maxLength = _minLength;
                                      }
                                    })
                                : null,
                          ),
                          Text(
                            '${l10n.hangmanMaxLength}: $_maxLength',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _maxLength.toDouble(),
                            min: 3,
                            max: 12,
                            divisions: 9,
                            label: '$_maxLength',
                            activeColor: accent,
                            onChanged: _phase == _HangmanPhase.idle
                                ? (v) => setState(() {
                                      _maxLength = v.round();
                                      if (_maxLength < _minLength) {
                                        _minLength = _maxLength;
                                      }
                                    })
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordDisplay extends StatelessWidget {
  const _WordDisplay({
    required this.word,
    required this.guessed,
    required this.accent,
  });

  final String word;
  final Set<String> guessed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: word.split('').map((letter) {
        final revealed = guessed.contains(letter);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              revealed ? letter : ' ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            Container(
              width: 22,
              height: 2,
              color: accent.withOpacity(0.6),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _LetterKeyboard extends StatelessWidget {
  const _LetterKeyboard({
    required this.guessed,
    required this.word,
    required this.accent,
    required this.onGuess,
  });

  final Set<String> guessed;
  final String word;
  final Color accent;
  final void Function(String) onGuess;

  static const _rows = ['ABCDEFGHI', 'JKLMNOPQR', 'STUVWXYZ'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              final isGuessed = guessed.contains(letter);
              final isCorrect = word.contains(letter);
              Color? fgColor;
              Color? bgColor;
              if (isGuessed) {
                fgColor = isCorrect
                    ? Colors.green
                    : Colors.redAccent.withOpacity(0.7);
                bgColor = isCorrect
                    ? Colors.green.withOpacity(0.12)
                    : Colors.redAccent.withOpacity(0.08);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  width: 34,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:
                          isGuessed ? bgColor : accent.withOpacity(0.12),
                      foregroundColor:
                          isGuessed ? fgColor : accent,
                      disabledForegroundColor: fgColor,
                      disabledBackgroundColor: bgColor,
                      side: BorderSide(
                        color: isGuessed
                            ? (isCorrect
                                ? Colors.green.withOpacity(0.5)
                                : Colors.redAccent.withOpacity(0.3))
                            : accent.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isGuessed ? null : () => onGuess(letter),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  const _HangmanPainter({
    required this.wrongGuesses,
    required this.accent,
  });

  final int wrongGuesses;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint scaffold = Paint()
      ..color = accent.withOpacity(0.55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint body = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;

    // Gallows: base, pole, beam, rope
    // Base
    canvas.drawLine(Offset(w * 0.1, h * 0.9), Offset(w * 0.5, h * 0.9), scaffold);
    // Pole
    canvas.drawLine(Offset(w * 0.25, h * 0.9), Offset(w * 0.25, h * 0.1), scaffold);
    // Beam
    canvas.drawLine(Offset(w * 0.25, h * 0.1), Offset(w * 0.65, h * 0.1), scaffold);
    // Rope
    canvas.drawLine(Offset(w * 0.65, h * 0.1), Offset(w * 0.65, h * 0.22), scaffold);

    if (wrongGuesses == 0) return;

    // Head
    canvas.drawCircle(Offset(w * 0.65, h * 0.30), h * 0.08, body);
    if (wrongGuesses == 1) return;

    // Body
    canvas.drawLine(Offset(w * 0.65, h * 0.38), Offset(w * 0.65, h * 0.62), body);
    if (wrongGuesses == 2) return;

    // Left arm
    canvas.drawLine(Offset(w * 0.65, h * 0.44), Offset(w * 0.50, h * 0.55), body);
    if (wrongGuesses == 3) return;

    // Right arm
    canvas.drawLine(Offset(w * 0.65, h * 0.44), Offset(w * 0.80, h * 0.55), body);
    if (wrongGuesses == 4) return;

    // Left leg
    canvas.drawLine(Offset(w * 0.65, h * 0.62), Offset(w * 0.50, h * 0.78), body);
    if (wrongGuesses == 5) return;

    // Right leg
    canvas.drawLine(Offset(w * 0.65, h * 0.62), Offset(w * 0.80, h * 0.78), body);
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.wrongGuesses != wrongGuesses;
}
