import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../storage/premium_store.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPro = context.watch<PremiumStore>().isPro;

    final pages = isPro
        ? const [HomePage(), AnalyticsPage(), SettingsPage()]
        : const [HomePage(), ProPage(), AnalyticsPage(), SettingsPage()];

    final destinations = isPro
        ? <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.grid_view),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart),
              label: l10n.navAnalytics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: l10n.navSettings,
            ),
          ]
        : <NavigationDestination>[
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
          ];

    // Clamp index in case tab count shrinks (e.g. user just bought Pro)
    final safeIndex = _index.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
