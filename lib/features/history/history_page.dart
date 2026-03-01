import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';

import '../../core/ui/app_colors.dart';
import '../../storage/history_store.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = context.watch<HistoryStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            tooltip: l10n.historyClearAll,
            onPressed: history.entries.isEmpty ? null : history.clearAll,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: history.entries.isEmpty
          ? Center(child: Text(l10n.historyEmpty))
          : ListView.separated(
              itemCount: history.entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = history.entries[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.generatorType.accentColor.withOpacity(
                      0.16,
                    ),
                    child: Icon(Icons.bolt, color: e.generatorType.accentColor),
                  ),
                  title: Text(e.value),
                  subtitle: Text(
                    l10n.historyItemSubtitle(
                      e.generatorType.localizedTitle(context),
                      e.timestamp.toString(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
