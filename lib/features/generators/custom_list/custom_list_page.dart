import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../storage/custom_lists_store.dart';
import '../../../models/generator_type.dart';
import '../../../storage/history_store.dart';
import '../../../storage/premium_store.dart';
import '../../../core/gating/feature_gate.dart';

class CustomListPage extends StatefulWidget {
  const CustomListPage({super.key});

  @override
  State<CustomListPage> createState() => _CustomListPageState();
}

class _CustomListPageState extends State<CustomListPage> {
  final _itemCtrl = TextEditingController();

  bool _withReplacement = true;
  String? _lastPicked;

  @override
  void dispose() {
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomListsStore>();
    final lists = store.lists;
    final selected = store.selectedList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom List'),
        actions: [
          IconButton(
            tooltip: 'New list',
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
                    value: store.selectedListId,
                    items: [
                      for (final l in lists)
                        DropdownMenuItem(value: l.id, child: Text(l.name)),
                    ],
                    onChanged: (id) => id == null ? null : store.selectList(id),
                    decoration: const InputDecoration(labelText: 'Select list'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Delete list',
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
                decoration: const InputDecoration(labelText: 'List name'),
                onChanged: (v) => store.renameSelected(v),
              ),

            const SizedBox(height: 16),

            // Mode toggle
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('With replacement'),
                    subtitle: Text(
                      _withReplacement
                          ? 'Picked item stays in the list'
                          : 'Picked item is removed (auto resets when empty)',
                    ),
                    value: _withReplacement,
                    onChanged: (v) => setState(() => _withReplacement = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pick result
            if (_lastPicked != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  'Picked: $_lastPicked',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: selected == null
                        ? null
                        : () async {
                            final history = context.read<HistoryStore>();
                            final gate = context.gateRead;

                            final picked = await store.drawFromSelected(
                              withReplacement: _withReplacement,
                            );
                            if (!mounted) return;

                            final value = picked ?? '(no items)';

                            await history.add(
                              type: GeneratorType.customList,
                              value: value,
                              maxEntries: gate.historyMax,
                            );

                            setState(() => _lastPicked = value);
                          },
                    child: const Text('Pick Random'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: selected == null
                      ? null
                      : store.restoreRemovedSelected,
                  child: const Text('Restore removed'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: selected == null ? null : store.resetAllSelected,
                  child: const Text('Reset all'),
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
                    decoration: const InputDecoration(
                      labelText: 'Add item',
                      hintText: 'e.g. Pizza',
                    ),
                    onSubmitted: (v) async {
                      await store.addItemToSelected(v);
                      _itemCtrl.clear();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () async {
                          await store.addItemToSelected(_itemCtrl.text);
                          _itemCtrl.clear();
                        },
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Items list
            Expanded(
              child: selected == null
                  ? const Center(child: Text('No list selected'))
                  : ListView.separated(
                      itemCount: selected.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
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
