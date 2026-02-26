import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/settings_store.dart';
import '../../storage/premium_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    final premium = context.watch<PremiumStore>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (m) => m == null ? null : settings.setThemeMode(m),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),

          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.languageCode),
            trailing: DropdownButton<String>(
              value: settings.languageCode,
              onChanged: (v) => v == null ? null : settings.setLanguageCode(v),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Pro (DEV toggle)'),
            subtitle: const Text(
              'Temporary switch until Store purchases are integrated',
            ),
            value: premium.isPro,
            onChanged: (v) => premium.setPro(v),
          ),
        ],
      ),
    );
  }
}
