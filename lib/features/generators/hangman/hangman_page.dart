import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/storage/settings_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

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
  int _roundsPlayed = 0;

  static const int _maxWrongGuesses = 6;

  List<String> _wordList = [];

  @override
  void initState() {
    super.initState();
    _loadWordList();
  }

  Future<void> _loadWordList() async {
    final lang = context.read<SettingsStore>().languageCode;
    final asset = 'assets/words/$lang.txt';
    try {
      final raw = await rootBundle.loadString(asset);
      final words = raw
          .split('\n')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();
      if (mounted) setState(() => _wordList = words);
    } catch (_) {
      // fallback to English if locale file missing
      final raw = await rootBundle.loadString('assets/words/en.txt');
      final words = raw
          .split('\n')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();
      if (mounted) setState(() => _wordList = words);
    }
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

  void _startGame() {
    if (!_checkRoundLimit()) return;
    final filtered = _wordList
        .where((w) => w.length >= 4 && w.length <= 10)
        .toList();
    if (filtered.isEmpty) return;

    setState(() {
      _word = filtered[_rng.nextInt(filtered.length)].toUpperCase();
      _guessed.clear();
      _wrongGuesses = 0;
      _phase = _HangmanPhase.playing;
    });
  }

  void _cancel() {
    setState(() {
      _phase = _HangmanPhase.idle;
      _word = '';
      _guessed.clear();
      _wrongGuesses = 0;
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
    final won = value.startsWith('Won');
    history.add(
      type: GeneratorType.hangman,
      value: value,
      maxEntries: context.gateRead.historyMax,
      metadata: {'won': won, 'wordLength': _word.length},
    );
  }

  List<String> get _wrongLetters =>
      _guessed.where((l) => !_word.contains(l)).toList()..sort();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = GeneratorType.hangman.accentColor;
    final gate = context.gateRead;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hangmanTitle),
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
                      generatorType: GeneratorType.hangman,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.hangman,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Central area ─────────────────────────────────────────────────
          Expanded(
            child: _phase == _HangmanPhase.idle
                // Idle: big title card (like reaction test / tap challenge)
                ? Padding(
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
                              l10n.hangmanTitle,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.hangmanDescription,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                // Playing / Won / Lost: hangman drawing + word
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _HangmanPainter(
                                wrongGuesses: _wrongGuesses,
                                accent: accent,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _WordDisplay(
                            word: _word,
                            guessed: _guessed,
                            accent: accent,
                          ),

                          const SizedBox(height: 12),

                          if (_phase == _HangmanPhase.playing)
                            Text(
                              l10n.hangmanAttemptsLeft(
                                _maxWrongGuesses - _wrongGuesses,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),

                          if (_wrongLetters.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.hangmanWrongLetters} ${_wrongLetters.join(' ')}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          if (_phase == _HangmanPhase.won) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.hangmanYouWon,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (_phase == _HangmanPhase.lost) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.hangmanYouLost(_word),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),

          // ── Bottom controls (sticky) ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_phase == _HangmanPhase.idle) ...[
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.hangmanNewGame),
                  ),
                ] else if (_phase == _HangmanPhase.playing) ...[
                  _LetterKeyboard(
                    guessed: _guessed,
                    word: _word,
                    accent: accent,
                    onGuess: _guessLetter,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _cancel,
                    child: Text(l10n.commonCancel),
                  ),
                ] else ...[
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
                    onPressed: _startGame,
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.hangmanPlayAgain),
                  ),
                ],
              ],
            ),
          ),
        ],
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
      runSpacing: 8,
      children: word.split('').map((letter) {
        final revealed = guessed.contains(letter);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              revealed ? letter : ' ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            Container(width: 24, height: 2.5, color: accent.withOpacity(0.6)),
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
                      backgroundColor: isGuessed
                          ? bgColor
                          : accent.withOpacity(0.12),
                      foregroundColor: isGuessed ? fgColor : accent,
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
  const _HangmanPainter({required this.wrongGuesses, required this.accent});

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

    // Base
    canvas.drawLine(
      Offset(w * 0.1, h * 0.9),
      Offset(w * 0.5, h * 0.9),
      scaffold,
    );
    // Pole
    canvas.drawLine(
      Offset(w * 0.25, h * 0.9),
      Offset(w * 0.25, h * 0.1),
      scaffold,
    );
    // Beam
    canvas.drawLine(
      Offset(w * 0.25, h * 0.1),
      Offset(w * 0.65, h * 0.1),
      scaffold,
    );
    // Rope
    canvas.drawLine(
      Offset(w * 0.65, h * 0.1),
      Offset(w * 0.65, h * 0.22),
      scaffold,
    );

    if (wrongGuesses == 0) return;

    // Head
    canvas.drawCircle(Offset(w * 0.65, h * 0.30), h * 0.08, body);
    if (wrongGuesses == 1) return;

    // Body
    canvas.drawLine(
      Offset(w * 0.65, h * 0.38),
      Offset(w * 0.65, h * 0.62),
      body,
    );
    if (wrongGuesses == 2) return;

    // Left arm
    canvas.drawLine(
      Offset(w * 0.65, h * 0.44),
      Offset(w * 0.50, h * 0.55),
      body,
    );
    if (wrongGuesses == 3) return;

    // Right arm
    canvas.drawLine(
      Offset(w * 0.65, h * 0.44),
      Offset(w * 0.80, h * 0.55),
      body,
    );
    if (wrongGuesses == 4) return;

    // Left leg
    canvas.drawLine(
      Offset(w * 0.65, h * 0.62),
      Offset(w * 0.50, h * 0.78),
      body,
    );
    if (wrongGuesses == 5) return;

    // Right leg
    canvas.drawLine(
      Offset(w * 0.65, h * 0.62),
      Offset(w * 0.80, h * 0.78),
      body,
    );
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.wrongGuesses != wrongGuesses;
}
