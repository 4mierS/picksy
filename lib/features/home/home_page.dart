import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';

import '../../core/gating/feature_gate.dart';
import '../../core/routing/generator_router.dart';
import '../../core/ui/app_colors.dart';
import '../../models/generator_type.dart';
import '../../storage/favorites_store.dart';
import '../../storage/history_store.dart';

import '../history/history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _generators = [
    GeneratorType.customList,
    GeneratorType.color,
    GeneratorType.number,
    GeneratorType.letter,
    GeneratorType.card,
    GeneratorType.time,
    GeneratorType.coin,
    GeneratorType.bottleSpin,
  ];

  static const _miniGames = [
    GeneratorType.reactionTest,
    GeneratorType.tapChallenge,
    GeneratorType.memoryFlash,
    GeneratorType.colorReflex,
    GeneratorType.ticTacToe,
    GeneratorType.connectFour,
    GeneratorType.hangman,
    GeneratorType.mathChallenge,
  ];

  static const _miniGamesSet = {
    GeneratorType.reactionTest,
    GeneratorType.tapChallenge,
    GeneratorType.memoryFlash,
    GeneratorType.colorReflex,
    GeneratorType.ticTacToe,
    GeneratorType.connectFour,
    GeneratorType.hangman,
    GeneratorType.mathChallenge,
  };

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _greeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.homeHistoryTooltip,
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Tab bar (pill/capsule style) ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  tabs: [
                    Tab(text: l10n.homeTabGenerators),
                    Tab(text: l10n.homeTabMiniGames),
                  ],
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: AppColors.proPurple,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.proPurple,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // ── Tab views ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _TabContent(items: _generators, miniGamesSet: _miniGamesSet),
                  _TabContent(items: _miniGames, miniGamesSet: _miniGamesSet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab content (favorites + grid) ────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  final List<GeneratorType> items;
  final Set<GeneratorType> miniGamesSet;

  const _TabContent({required this.items, required this.miniGamesSet});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favStore = context.watch<FavoritesStore>();
    final favorites = favStore.favorites.where((f) => items.contains(f)).toList();

    return CustomScrollView(
      slivers: [
        // ── Favorites section ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.homeFavorites,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        if (favorites.isNotEmpty)
          _GeneratorGrid(items: favorites, miniGamesSet: miniGamesSet)
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 15,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.homeFavoritesHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── All items ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l10n.homeAllGenerators,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        _GeneratorGrid(items: items, miniGamesSet: miniGamesSet),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────────────────────

class _GeneratorGrid extends StatelessWidget {
  final List<GeneratorType> items;
  final Set<GeneratorType> miniGamesSet;

  const _GeneratorGrid({required this.items, required this.miniGamesSet});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favStore = context.watch<FavoritesStore>();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = width >= 900
              ? 4
              : width >= 600
                  ? 3
                  : 2;

          return SliverGrid(
            delegate: SliverChildBuilderDelegate((context, i) {
              final t = items[i];
              final isFav = favStore.isFavorite(t);

              return _GeneratorTile(
                type: t,
                isFavorite: isFav,
                isGame: miniGamesSet.contains(t),
                onFavoriteToggle: () async {
                  final gate = context.gateRead;
                  final ok = await favStore.toggle(
                    t,
                    maxFavorites: gate.favoritesMax,
                  );

                  if (!ok && context.mounted) {
                    await showProDialog(
                      context,
                      title: l10n.homeFavoritesLimitReachedTitle,
                      message: l10n.homeFavoritesLimitReachedMessage,
                    );
                  }
                },
                onOpen: () => openGenerator(context, t),
              );
            }, childCount: items.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
          );
        },
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _GeneratorTile extends StatelessWidget {
  final GeneratorType type;
  final bool isFavorite;
  final bool isGame;
  final Future<void> Function() onFavoriteToggle;
  final VoidCallback onOpen;

  const _GeneratorTile({
    required this.type,
    required this.isFavorite,
    required this.isGame,
    required this.onFavoriteToggle,
    required this.onOpen,
  });

  IconData get _icon => type.homeIcon;

  Color get _accent => type.accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = context.watch<HistoryStore>();
    final entries = history.forGenerator(type);
    final lastResult = entries.isNotEmpty ? entries.first.value : null;

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accent.withValues(alpha: 0.18),
                _accent.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon, size: 28, color: _accent),
                    const Spacer(),
                    // ── Mini-game badge ──────────────────────────────────
                    if (isGame) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.sports_esports_rounded,
                          size: 12,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(width: 2),
                    ],
                    IconButton(
                      tooltip: isFavorite
                          ? l10n.homeUnfavorite
                          : l10n.homeFavorite,
                      onPressed: () => onFavoriteToggle(),
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? _accent : null,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  type.localizedTitle(context),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                // ── Last result or hint ──────────────────────────────────
                Text(
                  lastResult ?? l10n.homeTapToOpen,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: lastResult != null
                        ? _accent.withValues(alpha: 0.8)
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
