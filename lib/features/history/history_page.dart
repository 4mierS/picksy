import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/history_store.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            onPressed: history.entries.isEmpty ? null : history.clearAll,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: history.entries.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.separated(
              itemCount: history.entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = history.entries[i];
                return ListTile(
                  title: Text(e.value),
                  subtitle: Text('${e.generatorType.name} • ${e.timestamp}'),
                );
              },
            ),
    );
  }
}
