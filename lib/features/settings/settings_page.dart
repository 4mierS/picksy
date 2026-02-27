import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/settings_store.dart';
import '../../storage/premium_store.dart';
import '../../core/links.dart';

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

          ListTile(
            leading: const Icon(Icons.bug_report_rounded),
            title: const Text('Report Bug'),
            subtitle: const Text('Requires a GitHub account'),
            onTap: openBugReport,
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_rounded),
            title: const Text('Suggest Feature'),
            subtitle: const Text('Requires a GitHub account'),
            onTap: openFeatureRequest,
          ),
          ListTile(
            leading: const Icon(Icons.coffee_rounded),
            title: const Text('Support Picksy'),
            onTap: openCoffee,
          ),

          const Divider(height: 32),

          // ListTile(
          //   leading: const Icon(Icons.star_rate_rounded),
          //   title: const Text('Rate App'),
          //   onTap: () {
          //     openRateApp();
          //   },
          // ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Privacy Policy'),
            onTap: () {
              openPrivacyPolicy();
            },
          ),

          const SizedBox(height: 16),

          // Optional: kleine Info
          Text(
            premium.isPro ? 'Pro active ✅' : 'Free version',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
