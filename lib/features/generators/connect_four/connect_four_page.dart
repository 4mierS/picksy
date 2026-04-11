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
import 'package:picksy/storage/game_stats_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/game_widgets.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

// ---------------------------------------------------------------------------
// Private enums & constants
// ---------------------------------------------------------------------------

enum _Cell { empty, red, yellow }

enum _Phase { setup, playing, finished }

const _kBotName = 'BOT';
const _kDefaultPlayerName = 'PLAYER';
const _kGameKey = 'connect_four';
const _kRows = 6;
const _kCols = 7;

// ---------------------------------------------------------------------------
// AI – Connect Four
// ---------------------------------------------------------------------------

class _ConnectFourAI {
  final Random _rng = Random();

  int bestMove(List<List<_Cell>> board, _Cell botMark, Difficulty difficulty) {
    final validCols = _validColumns(board);
    if (validCols.isEmpty) return -1;

    switch (difficulty) {
      case Difficulty.medium:
        return _mediumMove(board, botMark, validCols);
      case Difficulty.hard:
        return _hardMove(board, botMark);
    }
  }

  int _randomMove(List<int> valid) => valid[_rng.nextInt(valid.length)];

  int _mediumMove(List<List<_Cell>> board, _Cell botMark, List<int> valid) {
    final humanMark = botMark == _Cell.red ? _Cell.yellow : _Cell.red;

    // Win if possible
    for (final col in valid) {
      if (_wouldWin(board, col, botMark)) return col;
    }
    // Block human
    for (final col in valid) {
      if (_wouldWin(board, col, humanMark)) return col;
    }
    // Prefer center
    const preferred = [3, 2, 4, 1, 5, 0, 6];
    for (final p in preferred) {
      if (valid.contains(p)) return p;
    }
    return _randomMove(valid);
  }

  int _hardMove(List<List<_Cell>> board, _Cell botMark) {
    const maxDepth = 5;
    int bestScore = -10000;
    int bestCol = _validColumns(board).first;

    for (final col in _validColumns(board)) {
      final b = _copyBoard(board);
      _dropPiece(b, col, botMark);
      final score = _minimax(b, maxDepth - 1, false, botMark, -10000, 10000);
      if (score > bestScore) {
        bestScore = score;
        bestCol = col;
      }
    }
    return bestCol;
  }

  int _minimax(
    List<List<_Cell>> board,
    int depth,
    bool isMax,
    _Cell botMark,
    int alpha,
    int beta,
  ) {
    final humanMark = botMark == _Cell.red ? _Cell.yellow : _Cell.red;
    final winner = _getWinner(board);
    if (winner == botMark) return 100 + depth;
    if (winner == humanMark) return -(100 + depth);
    if (_validColumns(board).isEmpty || depth == 0) {
      return _scoreBoard(board, botMark);
    }

    if (isMax) {
      int best = -10000;
      for (final col in _validColumns(board)) {
        final b = _copyBoard(board);
        _dropPiece(b, col, botMark);
        final score = _minimax(b, depth - 1, false, botMark, alpha, beta);
        best = max(best, score);
        alpha = max(alpha, best);
        if (beta <= alpha) break;
      }
      return best;
    } else {
      int best = 10000;
      for (final col in _validColumns(board)) {
        final b = _copyBoard(board);
        _dropPiece(b, col, humanMark);
        final score = _minimax(b, depth - 1, true, botMark, alpha, beta);
        best = min(best, score);
        beta = min(beta, best);
        if (beta <= alpha) break;
      }
      return best;
    }
  }

  int _scoreBoard(List<List<_Cell>> board, _Cell botMark) {
    int score = 0;
    final humanMark = botMark == _Cell.red ? _Cell.yellow : _Cell.red;
    // Center column preference
    for (int r = 0; r < _kRows; r++) {
      if (board[r][3] == botMark) score += 3;
      if (board[r][3] == humanMark) score -= 3;
    }
    // Horizontal windows
    for (int r = 0; r < _kRows; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        final window = [
          board[r][c],
          board[r][c + 1],
          board[r][c + 2],
          board[r][c + 3],
        ];
        score += _scoreWindow(window, botMark, humanMark);
      }
    }
    // Vertical windows
    for (int c = 0; c < _kCols; c++) {
      for (int r = 0; r <= _kRows - 4; r++) {
        final window = [
          board[r][c],
          board[r + 1][c],
          board[r + 2][c],
          board[r + 3][c],
        ];
        score += _scoreWindow(window, botMark, humanMark);
      }
    }
    return score;
  }

  int _scoreWindow(List<_Cell> window, _Cell bot, _Cell human) {
    final botCount = window.where((c) => c == bot).length;
    final humanCount = window.where((c) => c == human).length;
    final emptyCount = window.where((c) => c == _Cell.empty).length;

    if (botCount == 4) return 100;
    if (botCount == 3 && emptyCount == 1) return 5;
    if (botCount == 2 && emptyCount == 2) return 2;
    if (humanCount == 3 && emptyCount == 1) return -4;
    return 0;
  }

  bool _wouldWin(List<List<_Cell>> board, int col, _Cell mark) {
    final b = _copyBoard(board);
    _dropPiece(b, col, mark);
    return _getWinner(b) == mark;
  }

  List<int> _validColumns(List<List<_Cell>> board) {
    return [
      for (int c = 0; c < _kCols; c++)
        if (board[0][c] == _Cell.empty) c,
    ];
  }

  int _dropRow(List<List<_Cell>> board, int col) {
    for (int r = _kRows - 1; r >= 0; r--) {
      if (board[r][col] == _Cell.empty) return r;
    }
    return -1;
  }

  void _dropPiece(List<List<_Cell>> board, int col, _Cell mark) {
    final row = _dropRow(board, col);
    if (row >= 0) board[row][col] = mark;
  }

  List<List<_Cell>> _copyBoard(List<List<_Cell>> board) =>
      board.map((row) => List<_Cell>.from(row)).toList();

  _Cell? _getWinner(List<List<_Cell>> board) {
    // Horizontal
    for (int r = 0; r < _kRows; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        final m = board[r][c];
        if (m != _Cell.empty &&
            board[r][c + 1] == m &&
            board[r][c + 2] == m &&
            board[r][c + 3] == m)
          return m;
      }
    }
    // Vertical
    for (int c = 0; c < _kCols; c++) {
      for (int r = 0; r <= _kRows - 4; r++) {
        final m = board[r][c];
        if (m != _Cell.empty &&
            board[r + 1][c] == m &&
            board[r + 2][c] == m &&
            board[r + 3][c] == m)
          return m;
      }
    }
    // Diagonal /
    for (int r = 3; r < _kRows; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        final m = board[r][c];
        if (m != _Cell.empty &&
            board[r - 1][c + 1] == m &&
            board[r - 2][c + 2] == m &&
            board[r - 3][c + 3] == m)
          return m;
      }
    }
    // Diagonal \
    for (int r = 0; r <= _kRows - 4; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        final m = board[r][c];
        if (m != _Cell.empty &&
            board[r + 1][c + 1] == m &&
            board[r + 2][c + 2] == m &&
            board[r + 3][c + 3] == m)
          return m;
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class ConnectFourPage extends StatefulWidget {
  const ConnectFourPage({super.key});

  @override
  State<ConnectFourPage> createState() => _ConnectFourPageState();
}

class _ConnectFourPageState extends State<ConnectFourPage> {
  // Setup
  GameMode _mode = GameMode.bot;
  Difficulty _difficulty = Difficulty.medium;
  String _player1Name = _kDefaultPlayerName;
  String _player2Name = _kBotName;
  final _p1Controller = TextEditingController(text: _kDefaultPlayerName);
  final _p2Controller = TextEditingController(text: _kBotName);

  // Game
  _Phase _phase = _Phase.setup;
  late List<List<_Cell>> _board;
  bool _redTurn = true; // player1 = red, player2/bot = yellow
  String? _winnerName;
  bool _isDraw = false;
  Set<_WinCoord> _winCells = {};

  final _ai = _ConnectFourAI();
  bool _botThinking = false;
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    _board = _emptyBoard();
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color get _accent => GeneratorType.connectFour.accentColor;

  List<List<_Cell>> _emptyBoard() =>
      List.generate(_kRows, (_) => List.filled(_kCols, _Cell.empty));

  String _normalize(String name) => name.trim().toUpperCase();

  String get _currentPlayerName {
    if (_redTurn) return _normalize(_player1Name);
    return _mode == GameMode.bot ? _kBotName : _normalize(_player2Name);
  }

  int _dropRow(int col) {
    for (int r = _kRows - 1; r >= 0; r--) {
      if (_board[r][col] == _Cell.empty) return r;
    }
    return -1;
  }

  // ---------------------------------------------------------------------------
  // Game logic
  // ---------------------------------------------------------------------------

  void _startGame() {
    final p1 = _normalize(
      _p1Controller.text.isNotEmpty ? _p1Controller.text : _kDefaultPlayerName,
    );
    final p2 = _mode == GameMode.bot
        ? _kBotName
        : _normalize(
            _p2Controller.text.isNotEmpty ? _p2Controller.text : 'PLAYER 2',
          );

    setState(() {
      _player1Name = p1;
      _player2Name = p2;
      _board = _emptyBoard();
      _redTurn = true;
      _winnerName = null;
      _isDraw = false;
      _winCells = {};
      _phase = _Phase.playing;
      _botThinking = false;
    });
  }

  void _onColumnTap(int col) {
    if (_phase != _Phase.playing) return;
    if (_botThinking) return;
    if (_mode == GameMode.bot && !_redTurn) return;
    if (_board[0][col] != _Cell.empty) return; // column full

    _dropAndCheck(col);
  }

  void _dropAndCheck(int col) {
    final row = _dropRow(col);
    if (row < 0) return;

    final mark = _redTurn ? _Cell.red : _Cell.yellow;
    setState(() => _board[row][col] = mark);

    final winCells = _findWinCells(mark);
    if (winCells != null) {
      _endGame(
        _redTurn ? _normalize(_player1Name) : _normalize(_player2Name),
        winCells,
      );
      return;
    }

    // Draw check
    bool boardFull = _board[0].every((c) => c != _Cell.empty);
    if (boardFull) {
      _endGame(null, {});
      return;
    }

    setState(() => _redTurn = !_redTurn);

    if (_mode == GameMode.bot && !_redTurn) {
      _scheduleBotMove();
    }
  }

  void _scheduleBotMove() {
    setState(() => _botThinking = true);
    final delay = 300 + Random().nextInt(500);
    _botTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final botMark = _Cell.yellow;
      final move = _ai.bestMove(_board, botMark, _difficulty);
      setState(() => _botThinking = false);
      if (move >= 0) _dropAndCheck(move);
    });
  }

  Set<_WinCoord>? _findWinCells(_Cell mark) {
    // Horizontal
    for (int r = 0; r < _kRows; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        if (_board[r][c] == mark &&
            _board[r][c + 1] == mark &&
            _board[r][c + 2] == mark &&
            _board[r][c + 3] == mark) {
          return {
            _WinCoord(r, c),
            _WinCoord(r, c + 1),
            _WinCoord(r, c + 2),
            _WinCoord(r, c + 3),
          };
        }
      }
    }
    // Vertical
    for (int c = 0; c < _kCols; c++) {
      for (int r = 0; r <= _kRows - 4; r++) {
        if (_board[r][c] == mark &&
            _board[r + 1][c] == mark &&
            _board[r + 2][c] == mark &&
            _board[r + 3][c] == mark) {
          return {
            _WinCoord(r, c),
            _WinCoord(r + 1, c),
            _WinCoord(r + 2, c),
            _WinCoord(r + 3, c),
          };
        }
      }
    }
    // Diagonal /
    for (int r = 3; r < _kRows; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        if (_board[r][c] == mark &&
            _board[r - 1][c + 1] == mark &&
            _board[r - 2][c + 2] == mark &&
            _board[r - 3][c + 3] == mark) {
          return {
            _WinCoord(r, c),
            _WinCoord(r - 1, c + 1),
            _WinCoord(r - 2, c + 2),
            _WinCoord(r - 3, c + 3),
          };
        }
      }
    }
    // Diagonal \
    for (int r = 0; r <= _kRows - 4; r++) {
      for (int c = 0; c <= _kCols - 4; c++) {
        if (_board[r][c] == mark &&
            _board[r + 1][c + 1] == mark &&
            _board[r + 2][c + 2] == mark &&
            _board[r + 3][c + 3] == mark) {
          return {
            _WinCoord(r, c),
            _WinCoord(r + 1, c + 1),
            _WinCoord(r + 2, c + 2),
            _WinCoord(r + 3, c + 3),
          };
        }
      }
    }
    return null;
  }

  void _endGame(String? winnerName, Set<_WinCoord> winCells) {
    setState(() {
      _phase = _Phase.finished;
      _winnerName = winnerName;
      _isDraw = winnerName == null;
      _winCells = winCells;
    });
    _saveHistory(winnerName);
    _saveStats(winnerName);
  }

  Future<void> _saveHistory(String? winnerName) async {
    final history = context.read<HistoryStore>();
    final gate = context.gateRead;
    final value = _isDraw
        ? 'Draw'
        : '$winnerName wins vs ${winnerName == _normalize(_player1Name) ? _normalize(_player2Name) : _normalize(_player1Name)}';
    await history.add(
      type: GeneratorType.connectFour,
      value: value,
      maxEntries: gate.historyMax,
      metadata: {
        'winner': winnerName,
        'draw': _isDraw,
        'mode': _mode.name,
        'difficulty': _difficulty.name,
        'player1': _normalize(_player1Name),
        'player2': _normalize(_player2Name),
      },
    );
  }

  Future<void> _saveStats(String? winnerName) async {
    if (winnerName == null) return;
    final gate = context.gateRead;
    if (!gate.canUse(ProFeature.connectFourStats)) return;
    final stats = context.read<GameStatsStore>();
    await stats.recordWin(_kGameKey, winnerName);
  }

  void _resetToSetup() {
    _botTimer?.cancel();
    setState(() {
      _phase = _Phase.setup;
      _board = _emptyBoard();
      _redTurn = true;
      _winnerName = null;
      _isDraw = false;
      _winCells = {};
      _botThinking = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generatorConnectFour),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: l10n.gameStatsTitle,
            onPressed: () {
              final gate = context.gateRead;
              if (gate.canUse(ProFeature.analyticsAccess)) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GeneratorAnalyticsPage(
                      generatorType: GeneratorType.connectFour,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.gameStatsProTitle,
                  message: l10n.gameStatsProMessage,
                  generatorType: GeneratorType.connectFour,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _phase == _Phase.setup ? _buildSetup(l10n) : _buildGame(l10n),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Setup screen
  // ---------------------------------------------------------------------------

  Widget _buildSetup(dynamic l10n) {
    final gate = context.gate;
    final canNames = gate.canUse(ProFeature.connectFourCustomNames);
    final canDifficulty = gate.canUse(ProFeature.connectFourDifficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Title card ────────────────────────────────────────────────────────
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
                decoration: AppStyles.generatorResultCard(_accent),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.generatorConnectFour,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.connectFourDescription,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Sticky bottom controls ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game Mode
              GeneratorSectionTitle(l10n.gameModeLabel),
              const SizedBox(height: 8),
              GameModeSelector(
                selected: _mode,
                accentColor: _accent,
                onChanged: (m) async {
                  if (m == GameMode.local &&
                      !gate.canUse(ProFeature.connectFourLocalMultiplayer)) {
                    await showProDialog(
                      context,
                      title: l10n.gameLocalMultiplayerProTitle,
                      message: l10n.gameLocalMultiplayerProMessage,
                      generatorType: GeneratorType.connectFour,
                      featureDefinitions: [
                        l10n.gameModeLocal,
                        l10n.gameCustomNamesProTitle,
                        l10n.gameStatsTitle,
                      ],
                    );
                    return;
                  }
                  setState(() {
                    _mode = m;
                    _p2Controller.text =
                        m == GameMode.bot ? _kBotName : 'PLAYER 2';
                  });
                },
              ),

              const SizedBox(height: 12),

              // ── Player names (always rendered, P2 only shown in local) ─────
              Row(
                children: [
                  GeneratorSectionTitle(l10n.gamePlayerOneName),
                  if (!canNames) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.lock,
                      size: 13,
                      color: AppColors.proPurple,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _CompactNameField(
                      controller: _p1Controller,
                      hint: 'P1',
                      enabled: canNames,
                      onLockedTap: () => showProDialog(
                        context,
                        title: l10n.gameCustomNamesProTitle,
                        message: l10n.gameCustomNamesProMessage,
                        generatorType: GeneratorType.connectFour,
                      ),
                    ),
                  ),
                  if (_mode == GameMode.local) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompactNameField(
                        controller: _p2Controller,
                        hint: 'P2',
                        enabled: canNames,
                        onLockedTap: () => showProDialog(
                          context,
                          title: l10n.gameCustomNamesProTitle,
                          message: l10n.gameCustomNamesProMessage,
                          generatorType: GeneratorType.connectFour,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ── Difficulty (always takes space; hidden in local mode) ───────
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: _mode == GameMode.bot,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GeneratorSectionTitle(l10n.gameDifficultyLabel),
                        if (!canDifficulty) ...[
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
                    DifficultySelector(
                      selected: _difficulty,
                      enabled: canDifficulty,
                      accentColor: _accent,
                      onChanged: (d) async {
                        if (!canDifficulty) {
                          await showProDialog(
                            context,
                            title: l10n.gameDifficultyProTitle,
                            message: l10n.gameDifficultyProMessage,
                            generatorType: GeneratorType.connectFour,
                          );
                          return;
                        }
                        setState(() => _difficulty = d);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              FilledButton.icon(
                style: AppStyles.generatorButton(_accent),
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.gameStartGame),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Game screen
  // ---------------------------------------------------------------------------

  Widget _buildGame(dynamic l10n) {
    final isFinished = _phase == _Phase.finished;

    return Column(
      children: [
        // Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: AppStyles.generatorResultCard(_accent),
          child: Text(
            isFinished
                ? (_isDraw ? l10n.gameDraw : l10n.gameYouWin(_winnerName!))
                : (_botThinking
                      ? l10n.gameBotThinking
                      : l10n.gamePlayerTurn(_currentPlayerName)),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Color legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: Colors.red, name: _normalize(_player1Name)),
              const SizedBox(width: 20),
              _Legend(
                color: Colors.yellow.shade700,
                name: _normalize(_player2Name),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Board
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildBoard(),
            ),
          ),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              FilledButton.icon(
                style: AppStyles.generatorButton(_accent),
                onPressed: _startGame,
                icon: const Icon(Icons.replay_rounded),
                label: Text(l10n.gamePlayAgain),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _resetToSetup,
                child: Text(l10n.gameBackToSetup),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBoard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column tap targets
          Row(
            children: List.generate(_kCols, (col) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onColumnTap(col),
                  child: Container(
                    height: 28,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color:
                          (_phase == _Phase.playing &&
                              !_botThinking &&
                              _board[0][col] == _Cell.empty)
                          ? Colors.white70
                          : Colors.transparent,
                      size: 20,
                    ),
                  ),
                ),
              );
            }),
          ),
          // Grid rows
          ...List.generate(_kRows, (row) {
            return Row(
              children: List.generate(_kCols, (col) {
                final cell = _board[row][col];
                final isWin = _winCells.contains(_WinCoord(row, col));
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onColumnTap(col),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _cellColor(cell),
                            border: isWin
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                            boxShadow: isWin
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Color _cellColor(_Cell cell) {
    return switch (cell) {
      _Cell.empty => Colors.blue.shade900,
      _Cell.red => Colors.red,
      _Cell.yellow => Colors.yellow.shade700,
    };
  }
}

// ---------------------------------------------------------------------------
// Small reusable helpers (file-local)
// ---------------------------------------------------------------------------

class _CompactNameField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final VoidCallback onLockedTap;

  const _CompactNameField({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      onTap: !enabled ? onLockedTap : null,
    );
  }
}

class _WinCoord {
  final int row, col;
  const _WinCoord(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is _WinCoord && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

class _Legend extends StatelessWidget {
  final Color color;
  final String name;

  const _Legend({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
