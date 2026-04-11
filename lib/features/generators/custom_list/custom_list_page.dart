import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/team/team_splitter.dart';

import 'package:picksy/models/custom_list_model.dart';
import 'package:picksy/storage/custom_lists_store.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

class CustomListPage extends StatefulWidget {
  const CustomListPage({super.key});

  @override
  State<CustomListPage> createState() => _CustomListPageState();
}

class _CustomListPageState extends State<CustomListPage> {
  final _itemCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _withReplacement = true;
  String? _lastPicked;

  bool _teamMode = false;
  int _teamCount = 2;
  List<List<String>>? _lastTeams;

  @override
  void dispose() {
    _itemCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRandom(BuildContext context) async {
    final store = context.read<CustomListsStore>();
    final selected = store.selectedList;
    if (selected == null) return;

    final history = context.read<HistoryStore>();
    final gate = context.gateRead;
    final noItemsLabel = context.l10n.customListNoItems;

    final picked = await store.drawFromSelected(withReplacement: _withReplacement);
    if (!mounted) return;

    final value = picked ?? noItemsLabel;
    await history.add(
      type: GeneratorType.customList,
      value: value,
      maxEntries: gate.historyMax,
      metadata: {'listId': selected.id, 'value': value},
    );

    setState(() {
      _lastPicked = value;
      _lastTeams = null;
    });
  }

  Future<void> _generateTeams(BuildContext context) async {
    final store = context.read<CustomListsStore>();
    final selected = store.selectedList;
    if (selected == null) return;

    final people = selected.items.where((e) => e.trim().isNotEmpty).toList();
    final teams = splitIntoTeams(people: people, teamCount: _teamCount);

    setState(() {
      _lastTeams = teams;
      _lastPicked = null;
    });

    final history = context.read<HistoryStore>();
    final gate = context.gateRead;
    await history.add(
      type: GeneratorType.customList,
      value: _formatTeamsForHistory(teams),
      maxEntries: gate.historyMax,
    );
  }

  String _formatTeamsForHistory(List<List<String>> teams) {
    final l10n = context.l10n;
    final buf = StringBuffer();
    for (var i = 0; i < teams.length; i++) {
      buf.writeln(l10n.customListTeamHistoryLine(i + 1, teams[i].join(', ')));
    }
    return buf.toString().trim();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomListsStore store,
    CustomListModel selected,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.customListDeleteList,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '"${selected.name}"',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.customListDeleteList),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if ((confirmed ?? false) && mounted) {
      store.deleteList(selected.id);
      setState(() {
        _lastPicked = null;
        _lastTeams = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.watch<CustomListsStore>();
    final lists = store.lists;
    final selected = store.selectedList;
    final accent = GeneratorType.customList.accentColor;

    // Keep name controller in sync with selected list (without cursor jump while typing)
    final currentName = selected?.name ?? '';
    if (_nameCtrl.text != currentName) _nameCtrl.text = currentName;

    final showRestore = !_teamMode && !_withReplacement;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.analyticsTitle,
            onPressed: () {
              final gate = context.gateRead;
              if (gate.canUse(ProFeature.analyticsAccess)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GeneratorAnalyticsPage(
                      generatorType: GeneratorType.customList,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.customList,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Selector / name row ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.customListSelectList,
                      suffixIcon: lists.length > 1
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              tooltip: l10n.customListSelectList,
                              itemBuilder: (_) => [
                                for (final lst in lists)
                                  PopupMenuItem(
                                    value: lst.id,
                                    child: Text(lst.name),
                                  ),
                              ],
                              onSelected: (id) {
                                store.selectList(id);
                                setState(() {
                                  _lastPicked = null;
                                  _lastTeams = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: store.renameSelected,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: accent),
                  tooltip: l10n.customListNewList,
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: store.createNewList,
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.customListDeleteList,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: (lists.length <= 1 || selected == null)
                      ? null
                      : () => _confirmDelete(context, store, selected),
                ),
              ],
            ),
          ),

          // ── Add item row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.customListAddItem,
                      hintText: l10n.customListAddItemHint,
                    ),
                    onSubmitted: (v) async {
                      await store.addItemToSelected(v);
                      if (!mounted) return;
                      _itemCtrl.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: AppStyles.generatorButton(accent).copyWith(
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
                  ),
                  onPressed: selected == null
                      ? null
                      : () async {
                          await store.addItemToSelected(_itemCtrl.text);
                          if (!mounted) return;
                          _itemCtrl.clear();
                        },
                  child: Text(l10n.commonAdd),
                ),
              ],
            ),
          ),

          // ── Items + results (scrollable) ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              children: [
                // Picked result
                if (_lastPicked != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      _lastPicked!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Teams result
                if (_lastTeams != null) ...[
                  _teamsView(context, _lastTeams!),
                  const SizedBox(height: 10),
                ],

                // List items
                if (selected == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text(l10n.customListNoListSelected)),
                  )
                else if (selected.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text(l10n.customListNoItems)),
                  )
                else
                  for (var i = 0; i < selected.items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(selected.items[i])),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => store.removeItemFromSelected(i),
                          ),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),

          // ── Bottom controls (sticky) ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_teamMode)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: accent,
                    title: Text(l10n.customListWithReplacement),
                    subtitle: Text(
                      _withReplacement
                          ? l10n.customListWithReplacementOn
                          : l10n.customListWithReplacementOff,
                    ),
                    value: _withReplacement,
                    onChanged: (v) => setState(() => _withReplacement = v),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: accent,
                  title: Text(l10n.customListTeamMode),
                  subtitle: Text(
                    _teamMode
                        ? l10n.customListTeamModeOn
                        : l10n.customListTeamModeOff,
                  ),
                  value: _teamMode,
                  onChanged: (v) => setState(() {
                    _teamMode = v;
                    _lastTeams = null;
                    _lastPicked = null;
                  }),
                ),
                if (_teamMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(l10n.customListTeamsLabel),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _teamCount,
                          items: [
                            for (int i = 2; i <= 8; i++)
                              DropdownMenuItem(value: i, child: Text('$i')),
                          ],
                          onChanged: (v) =>
                              v == null ? null : setState(() => _teamCount = v),
                        ),
                        const Spacer(),
                        if (selected != null)
                          Text(
                            l10n.customListPeopleCount(selected.items.length),
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (showRestore) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: selected == null
                              ? null
                              : store.restoreRemovedSelected,
                          icon: const Icon(Icons.restore),
                          label: Text(l10n.customListRestoreRemoved),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: FilledButton.icon(
                        style: AppStyles.generatorButton(accent),
                        onPressed: selected == null
                            ? null
                            : () => _teamMode
                                  ? _generateTeams(context)
                                  : _pickRandom(context),
                        icon: Icon(
                          _teamMode
                              ? Icons.groups_rounded
                              : Icons.casino_rounded,
                        ),
                        label: Text(
                          _teamMode
                              ? l10n.customListGenerateTeams
                              : l10n.customListPickRandom,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamsView(BuildContext context, List<List<String>> teams) {
    final l10n = context.l10n;
    final accent = GeneratorType.customList.accentColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customListTeamsCardTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < teams.length; i++) ...[
            Text(
              l10n.customListTeamTitle(i + 1),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final name in teams[i]) Chip(label: Text(name)),
                if (teams[i].isEmpty)
                  Chip(label: Text(l10n.customListEmptyTeam)),
              ],
            ),
            if (i != teams.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
