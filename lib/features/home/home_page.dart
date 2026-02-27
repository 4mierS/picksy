import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';

import '../../core/gating/feature_gate.dart';
import '../../core/routing/generator_router.dart';
import '../../models/generator_type.dart';
import '../../storage/favorites_store.dart';

import '../history/history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _all = [
    GeneratorType.color,
    GeneratorType.number,
    GeneratorType.coin,
    GeneratorType.letter,
    GeneratorType.customList,
    GeneratorType.bottleSpin,
    GeneratorType.time,
    GeneratorType.reactionTest,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favStore = context.watch<FavoritesStore>();
    final favorites = favStore.favorites;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeSmartRandomDecisions,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
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
          ),

          if (favorites.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  l10n.homeFavorites,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _GeneratorGrid(items: favorites),
          ],

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.homeAllGenerators,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          _GeneratorGrid(items: _all),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _GeneratorGrid extends StatelessWidget {
  final List<GeneratorType> items;

  const _GeneratorGrid({required this.items});

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

class _GeneratorTile extends StatelessWidget {
  final GeneratorType type;
  final bool isFavorite;
  final Future<void> Function() onFavoriteToggle;
  final VoidCallback onOpen;

  const _GeneratorTile({
    required this.type,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onOpen,
  });

  IconData get _icon {
    switch (type) {
      case GeneratorType.color:
        return Icons.palette_outlined;
      case GeneratorType.number:
        return Icons.numbers;
      case GeneratorType.coin:
        return Icons.sync_alt;
      case GeneratorType.letter:
        return Icons.text_fields;
      case GeneratorType.customList:
        return Icons.list_alt;
      case GeneratorType.bottleSpin:
        return Icons.explore_outlined;
      case GeneratorType.time:
        return Icons.access_time;
      case GeneratorType.reactionTest:
        return Icons.flash_on;
    }
  }

  Color get _accent {
    switch (type) {
      case GeneratorType.color:
        return Colors.pinkAccent;
      case GeneratorType.number:
        return Colors.blueAccent;
      case GeneratorType.coin:
        return Colors.amber;
      case GeneratorType.letter:
        return Colors.teal;
      case GeneratorType.customList:
        return Colors.deepPurple;
      case GeneratorType.bottleSpin:
        return Colors.orange;
      case GeneratorType.time:
        return Colors.green;
      case GeneratorType.reactionTest:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              colors: [_accent.withOpacity(0.18), _accent.withOpacity(0.06)],
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
                const SizedBox(height: 6),
                Text(
                  l10n.homeTapToOpen,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
