import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

import '../features/home/home_page.dart';
import '../features/pro/pro_page.dart';
import '../features/analytics/analytics_page.dart';
import '../features/settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [HomePage(), ProPage(), AnalyticsPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.workspace_premium),
            label: l10n.navPro,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.navAnalytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
