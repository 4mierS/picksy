import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    final favStore = context.watch<FavoritesStore>();
    final favorites = favStore.favorites;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Random Builder',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'History',
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Favorites',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            _GeneratorGrid(items: favorites),
          ],

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'All Generators',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      title: 'Favorites limit reached',
                      message:
                          'Free users can pin up to 2 generators. Go Pro for unlimited favorites.',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon),
                    const Spacer(),
                    IconButton(
                      tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
                      onPressed: () => onFavoriteToggle(),
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  type.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to open',
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
