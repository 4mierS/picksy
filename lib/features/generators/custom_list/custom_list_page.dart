import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/ui/confirm_dialog.dart';
import 'package:picksy/core/team/team_splitter.dart';

import 'package:picksy/storage/custom_lists_store.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';

class CustomListPage extends StatefulWidget {
  const CustomListPage({super.key});

  @override
  State<CustomListPage> createState() => _CustomListPageState();
}

class _CustomListPageState extends State<CustomListPage> {
  final _itemCtrl = TextEditingController();

  bool _withReplacement = true;
  String? _lastPicked;

  bool _teamMode = false;
  int _teamCount = 2;
  List<List<String>>? _lastTeams;

  @override
  void dispose() {
    _itemCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRandom(BuildContext context) async {
    final store = context.read<CustomListsStore>();
    final selected = store.selectedList;
    if (selected == null) return;

    final history = context.read<HistoryStore>();
    final gate = context.gateRead;

    final picked = await store.drawFromSelected(
      withReplacement: _withReplacement,
    );
    if (!mounted) return;

    final value = picked ?? context.l10n.customListNoItems;

    await history.add(
      type: GeneratorType.customList,
      value: value,
      maxEntries: gate.historyMax,
    );

    setState(() {
      _lastPicked = value;
      _lastTeams = null; // optional: team result clear when picking
    });
  }

  Future<void> _generateTeams(BuildContext context) async {
    final store = context.read<CustomListsStore>();
    final selected = store.selectedList;
    if (selected == null) return;

    // People = items
    final people = selected.items.where((e) => e.trim().isNotEmpty).toList();

    final teams = splitIntoTeams(people: people, teamCount: _teamCount);

    setState(() {
      _lastTeams = teams;
      _lastPicked = null; // optional: pick result clear when generating teams
    });

    // Optional: store in history as a single entry (nice for portfolio)
    final history = context.read<HistoryStore>();
    final gate = context.gateRead;

    final formatted = _formatTeamsForHistory(teams);
    await history.add(
      type: GeneratorType.customList,
      value: formatted,
      maxEntries: gate.historyMax,
    );
  }

  String _formatTeamsForHistory(List<List<String>> teams) {
    final l10n = context.l10n;
    // compact, readable
    final buf = StringBuffer();
    for (var i = 0; i < teams.length; i++) {
      buf.writeln(l10n.customListTeamHistoryLine(i + 1, teams[i].join(', ')));
    }
    return buf.toString().trim();
  }

  Widget _teamsView(BuildContext context, List<List<String>> teams) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.glassCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customListTeamsCardTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < teams.length; i++) ...[
            Text(
              l10n.customListTeamTitle(i + 1),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in teams[i]) Chip(label: Text(name)),
                if (teams[i].isEmpty)
                  Chip(label: Text(l10n.customListEmptyTeam)),
              ],
            ),
            if (i != teams.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = context.watch<CustomListsStore>();
    final lists = store.lists;
    final selected = store.selectedList;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customListTitle),
        actions: [
          IconButton(
            tooltip: l10n.customListNewList,
            icon: const Icon(Icons.add),
            onPressed: store.createNewList,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // List selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: store.selectedListId,
                    items: [
                      for (final l in lists)
                        DropdownMenuItem(value: l.id, child: Text(l.name)),
                    ],
                    onChanged: (id) => id == null ? null : store.selectList(id),
                    decoration: InputDecoration(
                      labelText: l10n.customListSelectList,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: l10n.customListDeleteList,
                  onPressed: (lists.length <= 1 || selected == null)
                      ? null
                      : () => store.deleteList(selected.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Rename
            if (selected != null)
              TextFormField(
                initialValue: selected.name,
                decoration: InputDecoration(labelText: l10n.customListListName),
                onChanged: (v) => store.renameSelected(v),
              ),

            const SizedBox(height: 16),

            // Mode toggle (with replacement)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
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

            if (_teamMode) ...[
              const SizedBox(height: 6),
              Row(
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
                  Text(
                    selected == null
                        ? ''
                        : l10n.customListPeopleCount(selected.items.length),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Pick result
            if (_lastPicked != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: AppStyles.glassCard(context),
                child: Text(
                  l10n.customListPicked(_lastPicked!),
                  style: AppStyles.resultStyle,
                ),
              ),

            // Team result
            if (_lastTeams != null) ...[
              const SizedBox(height: 12),
              _teamsView(context, _lastTeams!),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: selected == null
                    ? null
                    : () => _teamMode
                          ? _generateTeams(context)
                          : _pickRandom(context),
                icon: Icon(
                  _teamMode ? Icons.groups_rounded : Icons.casino_rounded,
                ),
                label: Text(
                  _teamMode
                      ? l10n.customListGenerateTeams
                      : l10n.customListPickRandom,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Secondary actions (wrap -> no squeeze)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: selected == null
                      ? null
                      : store.restoreRemovedSelected,
                  icon: const Icon(Icons.restore),
                  label: Text(l10n.customListRestoreRemoved),
                ),
                OutlinedButton.icon(
                  onPressed: selected == null
                      ? null
                      : () async {
                          final ok = await showConfirmDialog(
                            context: context,
                            title: l10n.customListResetAllTitle,
                            message: l10n.customListResetAllMessage,
                            confirmText: l10n.customListResetAllConfirm,
                            cancelText: l10n.commonCancel,
                          );

                          if (ok) {
                            context.read<CustomListsStore>().resetAllSelected();
                            if (!mounted) return;
                            setState(() {
                              _lastPicked = null;
                              _lastTeams = null;
                            });
                          }
                        },
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: Text(l10n.customListResetAll),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Add item
            Row(
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
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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

            const SizedBox(height: 12),

            // Items list
            Expanded(
              child: selected == null
                  ? Center(child: Text(l10n.customListNoListSelected))
                  : ListView.separated(
                      itemCount: selected.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = selected.items[i];
                        return ListTile(
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => store.removeItemFromSelected(i),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
