import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/l10n/app_localizations.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/game_stats_store.dart';

// ---------------------------------------------------------------------------
// Enums shared between Tic Tac Toe and Connect Four
// ---------------------------------------------------------------------------

enum GameMode { bot, local }

enum Difficulty { medium, hard }

// ---------------------------------------------------------------------------
// Mode selector row
// ---------------------------------------------------------------------------

class GameModeSelector extends StatelessWidget {
  final GameMode selected;
  final ValueChanged<GameMode> onChanged;
  final Color accentColor;

  const GameModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GameModeButton(
              label: l10n.gameModeBot,
              icon: Icons.smart_toy_outlined,
              selected: selected == GameMode.bot,
              accentColor: accentColor,
              onTap: () => onChanged(GameMode.bot),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GameModeButton(
              label: l10n.gameModeLocal,
              icon: Icons.people_outlined,
              selected: selected == GameMode.local,
              accentColor: accentColor,
              onTap: () => onChanged(GameMode.local),
              badge: l10n.gameModePro,
            ),
          ),
        ],
      ),
    );
  }
}

class GameModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  final String? badge;

  const GameModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : Colors.grey.shade400,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.proPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.proPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Difficulty selector row
// ---------------------------------------------------------------------------

class DifficultySelector extends StatelessWidget {
  final Difficulty selected;
  final bool enabled;
  final ValueChanged<Difficulty> onChanged;
  final Color accentColor;

  const DifficultySelector({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: Difficulty.values.map((d) {
        final isSelected = selected == d;
        final label = switch (d) {
          Difficulty.medium => l10n.gameDifficultyMedium,
          Difficulty.hard => l10n.gameDifficultyHard,
        };
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (enabled ? accentColor : Colors.grey)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? (enabled ? accentColor : Colors.grey)
                        : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistics card
// ---------------------------------------------------------------------------

class GameStatsCard extends StatelessWidget {
  final String gameKey;
  final Color accentColor;
  final ProFeature proFeature;
  final GeneratorType generatorType;

  const GameStatsCard({
    super.key,
    required this.gameKey,
    required this.accentColor,
    required this.proFeature,
    required this.generatorType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;

    if (!gate.canUse(proFeature)) {
      return GestureDetector(
        onTap: () => showProDialog(
          context,
          title: l10n.gameStatsProTitle,
          message: l10n.gameStatsProMessage,
          generatorType: generatorType,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppColors.proPurple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.gameStatsTitle} – ${l10n.gameModePro}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.proPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final statsStore = context.watch<GameStatsStore>();
    final stats = statsStore.statsForGame(gameKey);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.gameStatsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _confirmClear(context, l10n),
                  child: Text(
                    l10n.gameStatsClear,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.proPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (stats.isEmpty)
              Text(
                l10n.gameStatsNoData,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              )
            else
              ..._sortedStats(stats).map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        l10n.gameStatsWins(e.value),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _sortedStats(Map<String, int> stats) {
    final entries = stats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Future<void> _confirmClear(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.gameStatsClear),
        content: Text(l10n.gameStatsClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<GameStatsStore>().clearGame(gameKey);
    }
  }
}
