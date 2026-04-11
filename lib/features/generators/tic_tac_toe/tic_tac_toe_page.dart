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

enum _Cell { empty, x, o }

enum _Phase { setup, playing, finished }

const _kBotName = 'BOT';
const _kDefaultPlayerName = 'PLAYER';
const _kGameKey = 'tic_tac_toe';
const _kMaxMarks = 3;
const _kFadingOpacity = 0.4;

// ---------------------------------------------------------------------------
// AI – Tic Tac Toe
// ---------------------------------------------------------------------------

class _TicTacToeAI {
  int bestMove(
    List<_Cell> board,
    _Cell botMark,
    Difficulty difficulty, {
    bool infinityMode = false,
    List<int>? botQueue,
    List<int>? humanQueue,
  }) {
    if (infinityMode && botQueue != null && humanQueue != null) {
      return _infinityMove(board, botMark, botQueue, humanQueue);
    }
    final empty = _emptyIndices(board);
    if (empty.isEmpty) return -1;

    switch (difficulty) {
      case Difficulty.medium:
        return _mediumMove(board, botMark, empty);
      case Difficulty.hard:
        return _minimaxBestMove(board, botMark);
    }
  }

  /// Applies an infinity-mode move to a copy of the board and returns the result.
  /// If the player's queue already has [_kMaxMarks] marks, the oldest is removed first.
  (List<_Cell>, List<int>) _applyInfinityMove(
    List<_Cell> board,
    List<int> queue,
    _Cell mark,
    int idx,
  ) {
    final newBoard = List<_Cell>.from(board);
    final newQueue = List<int>.from(queue);
    if (newQueue.length >= _kMaxMarks) {
      newBoard[newQueue[0]] = _Cell.empty;
      newQueue.removeAt(0);
    }
    newBoard[idx] = mark;
    newQueue.add(idx);
    return (newBoard, newQueue);
  }

  int _infinityMove(
    List<_Cell> board,
    _Cell botMark,
    List<int> botQueue,
    List<int> humanQueue,
  ) {
    final humanMark = botMark == _Cell.x ? _Cell.o : _Cell.x;
    final empty = _emptyIndices(board);
    if (empty.isEmpty) return -1;

    // 1. Win immediately
    for (final idx in empty) {
      final (newBoard, _) = _applyInfinityMove(board, botQueue, botMark, idx);
      if (_checkWinner(newBoard) == botMark) return idx;
    }
    // 2. Block human from winning on their next move
    for (final idx in empty) {
      final (newBoard, _) =
          _applyInfinityMove(board, humanQueue, humanMark, idx);
      if (_checkWinner(newBoard) == humanMark) return idx;
    }
    // 3. Center
    if (empty.contains(4)) return 4;
    // 4. Corner
    for (final corner in const [0, 2, 6, 8]) {
      if (empty.contains(corner)) return corner;
    }
    // 5. Any remaining empty cell
    return empty[Random().nextInt(empty.length)];
  }

  int _mediumMove(List<_Cell> board, _Cell botMark, List<int> empty) {
    final humanMark = botMark == _Cell.x ? _Cell.o : _Cell.x;
    // 1. Win if possible
    for (final idx in empty) {
      final b = List<_Cell>.from(board)..[idx] = botMark;
      if (_checkWinner(b) == botMark) return idx;
    }
    // 2. Block opponent win
    for (final idx in empty) {
      final b = List<_Cell>.from(board)..[idx] = humanMark;
      if (_checkWinner(b) == humanMark) return idx;
    }
    // 3. Create a fork (two simultaneous winning threats)
    for (final idx in empty) {
      final b = List<_Cell>.from(board)..[idx] = botMark;
      if (_countThreats(b, botMark) >= 2) return idx;
    }
    // 4. Block opponent fork
    for (final idx in empty) {
      final b = List<_Cell>.from(board)..[idx] = humanMark;
      if (_countThreats(b, humanMark) >= 2) return idx;
    }
    // 5. Center
    if (empty.contains(4)) return 4;
    // 6. Any empty corner
    for (final corner in const [0, 2, 6, 8]) {
      if (empty.contains(corner)) return corner;
    }
    // 7. Any remaining edge
    return empty.first;
  }

  int _countThreats(List<_Cell> board, _Cell mark) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    int threats = 0;
    for (final line in lines) {
      final cells = line.map((i) => board[i]).toList();
      if (cells.where((c) => c == mark).length == 2 &&
          cells.contains(_Cell.empty)) {
        threats++;
      }
    }
    return threats;
  }

  int _minimaxBestMove(List<_Cell> board, _Cell botMark) {
    int bestScore = -1000;
    int bestIdx = -1;
    final humanMark = botMark == _Cell.x ? _Cell.o : _Cell.x;
    for (final idx in _emptyIndices(board)) {
      final b = List<_Cell>.from(board)..[idx] = botMark;
      final score = _minimax(b, false, botMark, humanMark, 0);
      if (score > bestScore) {
        bestScore = score;
        bestIdx = idx;
      }
    }
    return bestIdx;
  }

  int _minimax(
    List<_Cell> board,
    bool isMaximizing,
    _Cell botMark,
    _Cell humanMark,
    int depth,
  ) {
    final winner = _checkWinner(board);
    if (winner == botMark) return 10 - depth;
    if (winner == humanMark) return depth - 10;
    if (_emptyIndices(board).isEmpty) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (final idx in _emptyIndices(board)) {
        board[idx] = botMark;
        best = max(best, _minimax(board, false, botMark, humanMark, depth + 1));
        board[idx] = _Cell.empty;
      }
      return best;
    } else {
      int best = 1000;
      for (final idx in _emptyIndices(board)) {
        board[idx] = humanMark;
        best = min(best, _minimax(board, true, botMark, humanMark, depth + 1));
        board[idx] = _Cell.empty;
      }
      return best;
    }
  }

  List<int> _emptyIndices(List<_Cell> board) => [
    for (int i = 0; i < board.length; i++)
      if (board[i] == _Cell.empty) i,
  ];

  _Cell? _checkWinner(List<_Cell> board) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = board[line[0]];
      if (a != _Cell.empty && a == board[line[1]] && a == board[line[2]]) {
        return a;
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  GameMode _mode = GameMode.bot;
  Difficulty _difficulty = Difficulty.medium;
  String _player1Name = _kDefaultPlayerName;
  String _player2Name = _kBotName;
  final _p1Controller = TextEditingController(text: _kDefaultPlayerName);
  final _p2Controller = TextEditingController(text: _kBotName);

  _Phase _phase = _Phase.setup;
  List<_Cell> _board = List.filled(9, _Cell.empty);
  bool _xTurn = true;
  String? _winnerName;
  bool _isDraw = false;
  List<int> _winLine = [];

  bool _infinityMode = false;
  final List<int> _xQueue = [];
  final List<int> _oQueue = [];

  final _ai = _TicTacToeAI();
  bool _botThinking = false;
  Timer? _botTimer;
  int _roundsPlayed = 0;

  @override
  void dispose() {
    _botTimer?.cancel();
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  Color get _accent => GeneratorType.ticTacToe.accentColor;

  String _normalize(String name) => name.trim().toUpperCase();

  String get _currentPlayerName {
    if (_xTurn) return _normalize(_player1Name);
    return _mode == GameMode.bot ? _kBotName : _normalize(_player2Name);
  }

  // ---------------------------------------------------------------------------
  // Game logic
  // ---------------------------------------------------------------------------

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
      _board = List.filled(9, _Cell.empty);
      _xTurn = true;
      _winnerName = null;
      _isDraw = false;
      _winLine = [];
      _phase = _Phase.playing;
      _botThinking = false;
      _xQueue.clear();
      _oQueue.clear();
    });
  }

  void _onCellTap(int index) {
    if (_phase != _Phase.playing) return;
    if (_board[index] != _Cell.empty) return;
    if (_botThinking) return;
    if (_mode == GameMode.bot && !_xTurn) return;
    _makeMove(index);
  }

  void _makeMove(int index) {
    if (_board[index] != _Cell.empty) return;
    final currentMark = _xTurn ? _Cell.x : _Cell.o;
    final currentQueue = _xTurn ? _xQueue : _oQueue;
    setState(() {
      if (_infinityMode && currentQueue.length >= _kMaxMarks) {
        _board[currentQueue[0]] = _Cell.empty;
        currentQueue.removeAt(0);
      }
      _board[index] = currentMark;
      currentQueue.add(index);
    });

    final winner = _checkWinner();
    if (winner != null) {
      _endGame(
        winner == _Cell.x ? _normalize(_player1Name) : _normalize(_player2Name),
      );
      return;
    }
    if (!_infinityMode && _board.every((c) => c != _Cell.empty)) {
      _endGame(null);
      return;
    }

    setState(() => _xTurn = !_xTurn);
    if (_mode == GameMode.bot && !_xTurn) _scheduleBotMove();
  }

  void _scheduleBotMove() {
    setState(() => _botThinking = true);
    final delay = 300 + Random().nextInt(500);
    _botTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final move = _ai.bestMove(
        _board,
        _Cell.o,
        _difficulty,
        infinityMode: _infinityMode,
        botQueue: _oQueue,
        humanQueue: _xQueue,
      );
      setState(() => _botThinking = false);
      if (move >= 0) _makeMove(move);
    });
  }

  _Cell? _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = _board[line[0]];
      if (a != _Cell.empty && a == _board[line[1]] && a == _board[line[2]]) {
        _winLine = line;
        return a;
      }
    }
    return null;
  }

  void _endGame(String? winnerName) {
    setState(() {
      _phase = _Phase.finished;
      _winnerName = winnerName;
      _isDraw = winnerName == null;
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
      type: GeneratorType.ticTacToe,
      value: value,
      maxEntries: gate.historyMax,
      metadata: {
        'winner': winnerName,
        'draw': _isDraw,
        'mode': _mode.name,
        'difficulty': _difficulty.name,
        'player1': _normalize(_player1Name),
        'player2': _normalize(_player2Name),
        'infinityMode': _infinityMode,
      },
    );
  }

  Future<void> _saveStats(String? winnerName) async {
    if (winnerName == null) return;
    final gate = context.gateRead;
    if (!gate.canUse(ProFeature.ticTacToeStats)) return;
    await context.read<GameStatsStore>().recordWin(_kGameKey, winnerName);
  }

  void _resetToSetup() {
    _botTimer?.cancel();
    setState(() {
      _phase = _Phase.setup;
      _board = List.filled(9, _Cell.empty);
      _xTurn = true;
      _winnerName = null;
      _isDraw = false;
      _winLine = [];
      _botThinking = false;
      _xQueue.clear();
      _oQueue.clear();
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
        title: Text(l10n.generatorTicTacToe),
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
                      generatorType: GeneratorType.ticTacToe,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.gameStatsProTitle,
                  message: l10n.gameStatsProMessage,
                  generatorType: GeneratorType.ticTacToe,
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

  Widget _buildSetup(dynamic l10n) {
    final gate = context.gate;
    final canNames = gate.canUse(ProFeature.ticTacToeCustomNames);
    final canDifficulty = gate.canUse(ProFeature.ticTacToeDifficulty);

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
                      l10n.generatorTicTacToe,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ticTacToeDescription,
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
                      !gate.canUse(ProFeature.ticTacToeLocalMultiplayer)) {
                    await showProDialog(
                      context,
                      title: l10n.gameLocalMultiplayerProTitle,
                      message: l10n.gameLocalMultiplayerProMessage,
                      generatorType: GeneratorType.ticTacToe,
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
                        generatorType: GeneratorType.ticTacToe,
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
                          generatorType: GeneratorType.ticTacToe,
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
                            generatorType: GeneratorType.ticTacToe,
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

              // Infinity Mode
              GeneratorSectionTitle(l10n.gameInfinityMode),
              const SizedBox(height: 8),
              _OffOnRow(
                value: _infinityMode,
                accent: _accent,
                onChanged: (v) => setState(() => _infinityMode = v),
              ),

              const SizedBox(height: 16),

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

  Widget _buildGame(dynamic l10n) {
    final isFinished = _phase == _Phase.finished;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: AppStyles.generatorResultCard(_accent),
          child: Column(
            children: [
              if (_infinityMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.all_inclusive_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.gameInfinityMode,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBoard(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: AppStyles.generatorButton(_accent),
                onPressed: _startGame,
                icon: const Icon(Icons.replay_rounded),
                label: Text(l10n.gamePlayAgain),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _resetToSetup,
                child: Text(l10n.gameBackToSetup),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    // Determine which index (if any) will be removed on the NEXT move.
    // In infinity mode, that is the oldest mark of the current player when
    // they already hold [_kMaxMarks] marks.
    int? nextRemovalIndex;
    if (_infinityMode && _phase == _Phase.playing) {
      final currentQueue = _xTurn ? _xQueue : _oQueue;
      if (currentQueue.length >= _kMaxMarks) {
        nextRemovalIndex = currentQueue.first;
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final cell = _board[index];
        final isWinCell = _winLine.contains(index);
        final isNextRemoval = index == nextRemovalIndex;
        return GestureDetector(
          onTap: () => _onCellTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isWinCell
                  ? _accent.withOpacity(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWinCell
                    ? _accent
                    : isNextRemoval
                    ? Colors.orange.shade400
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: _buildCellContent(cell, fading: isNextRemoval),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCellContent(_Cell cell, {bool fading = false}) {
    if (cell == _Cell.empty) return const SizedBox();
    return Opacity(
      opacity: fading ? _kFadingOpacity : 1.0,
      child: Text(
        cell == _Cell.x ? 'X' : 'O',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: cell == _Cell.x ? _accent : Colors.deepOrange,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable helpers (file-local)
// ---------------------------------------------------------------------------

/// Compact text field for player name entry.
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

/// Off / On OutlinedButton toggle row (consistent with other generators).
class _OffOnRow extends StatelessWidget {
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _OffOnRow({
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: !value ? accent : null,
              side: BorderSide(
                color: !value ? accent : Colors.grey.withOpacity(0.4),
                width: !value ? 2 : 1,
              ),
              backgroundColor: !value ? accent.withOpacity(0.1) : null,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: () => onChanged(false),
            child: const Text('Off'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: value ? accent : null,
              side: BorderSide(
                color: value ? accent : Colors.grey.withOpacity(0.4),
                width: value ? 2 : 1,
              ),
              backgroundColor: value ? accent.withOpacity(0.1) : null,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: () => onChanged(true),
            child: const Text('On'),
          ),
        ),
      ],
    );
  }
}
