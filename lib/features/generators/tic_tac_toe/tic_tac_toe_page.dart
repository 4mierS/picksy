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
import 'package:picksy/storage/game_stats_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/game_widgets.dart';

// ---------------------------------------------------------------------------
// Private enums & constants
// ---------------------------------------------------------------------------

enum _Cell { empty, x, o }

enum _Phase { setup, playing, finished }

const _kBotName = 'BOT';
const _kDefaultPlayerName = 'PLAYER';
const _kGameKey = 'tic_tac_toe';

// ---------------------------------------------------------------------------
// AI – Tic Tac Toe
// ---------------------------------------------------------------------------

class _TicTacToeAI {
  int bestMove(List<_Cell> board, _Cell botMark, Difficulty difficulty) {
    final empty = _emptyIndices(board);
    if (empty.isEmpty) return -1;

    switch (difficulty) {
      case Difficulty.medium:
        return _mediumMove(board, botMark, empty);
      case Difficulty.hard:
        return _minimaxBestMove(board, botMark);
    }
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

  final _ai = _TicTacToeAI();
  bool _botThinking = false;
  Timer? _botTimer;

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
      _board = List.filled(9, _Cell.empty);
      _xTurn = true;
      _winnerName = null;
      _isDraw = false;
      _winLine = [];
      _phase = _Phase.playing;
      _botThinking = false;
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
    setState(() => _board[index] = _xTurn ? _Cell.x : _Cell.o);

    final winner = _checkWinner();
    if (winner != null) {
      _endGame(
        winner == _Cell.x ? _normalize(_player1Name) : _normalize(_player2Name),
      );
      return;
    }
    if (_board.every((c) => c != _Cell.empty)) {
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
      final move = _ai.bestMove(_board, _Cell.o, _difficulty);
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

  Widget _buildSetup(AppLocalizations l10n) {
    final gate = context.gate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero
        Container(
          decoration: AppStyles.generatorResultCard(_accent),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(
                GeneratorType.ticTacToe.homeIcon,
                size: 56,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.generatorTicTacToe,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Game mode
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.gameModeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
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
                      _p2Controller.text = m == GameMode.bot
                          ? _kBotName
                          : 'PLAYER 2';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Player names
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NameField(
                  label: l10n.gamePlayerOneName,
                  controller: _p1Controller,
                  enabled: gate.canUse(ProFeature.ticTacToeCustomNames),
                  onLockedTap: () => showProDialog(
                    context,
                    title: l10n.gameCustomNamesProTitle,
                    message: l10n.gameCustomNamesProMessage,
                    generatorType: GeneratorType.ticTacToe,
                  ),
                  hint: l10n.gamePlayerNameHint,
                ),
                if (_mode == GameMode.local) ...[
                  const SizedBox(height: 12),
                  _NameField(
                    label: l10n.gamePlayerTwoName,
                    controller: _p2Controller,
                    enabled: gate.canUse(ProFeature.ticTacToeCustomNames),
                    onLockedTap: () => showProDialog(
                      context,
                      title: l10n.gameCustomNamesProTitle,
                      message: l10n.gameCustomNamesProMessage,
                      generatorType: GeneratorType.ticTacToe,
                    ),
                    hint: l10n.gamePlayerNameHint,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Difficulty
        if (_mode == GameMode.bot)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DifficultyHeader(
                    label: l10n.gameDifficultyLabel,
                    locked: !gate.canUse(ProFeature.ticTacToeDifficulty),
                    proLabel: l10n.gameModePro,
                  ),
                  const SizedBox(height: 10),
                  DifficultySelector(
                    selected: _difficulty,
                    enabled: gate.canUse(ProFeature.ticTacToeDifficulty),
                    accentColor: _accent,
                    onChanged: (d) async {
                      if (!gate.canUse(ProFeature.ticTacToeDifficulty)) {
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
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),

        // Stats
        GameStatsCard(
          gameKey: _kGameKey,
          accentColor: _accent,
          proFeature: ProFeature.ticTacToeStats,
          generatorType: GeneratorType.ticTacToe,
        ),
        const SizedBox(height: 12),

        // Hint
        Container(
          decoration: AppStyles.proCard(),
          padding: const EdgeInsets.all(14),
          child: Text(
            l10n.gameFreeProHint,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),

        FilledButton.icon(
          style: AppStyles.generatorButton(_accent),
          onPressed: _startGame,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(l10n.gameStartGame),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGame(AppLocalizations l10n) {
    final isFinished = _phase == _Phase.finished;
    return Column(
      children: [
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
                color: isWinCell ? _accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(child: _buildCellContent(cell)),
          ),
        );
      },
    );
  }

  Widget _buildCellContent(_Cell cell) {
    if (cell == _Cell.empty) return const SizedBox();
    return Text(
      cell == _Cell.x ? 'X' : 'O',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: cell == _Cell.x ? _accent : Colors.deepOrange,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable helpers (file-local)
// ---------------------------------------------------------------------------

class _NameField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onLockedTap;
  final String hint;

  const _NameField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onLockedTap,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (!enabled) ...[
              const SizedBox(width: 6),
              const Icon(Icons.lock, size: 14, color: AppColors.proPurple),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onTap: !enabled ? onLockedTap : null,
        ),
      ],
    );
  }
}

class _DifficultyHeader extends StatelessWidget {
  final String label;
  final bool locked;
  final String proLabel;

  const _DifficultyHeader({
    required this.label,
    required this.locked,
    required this.proLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        if (locked) ...[
          const SizedBox(width: 6),
          const Icon(Icons.lock, size: 14, color: AppColors.proPurple),
          const SizedBox(width: 4),
          Text(
            proLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.proPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
