import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../storage/settings_store.dart';
import '../../storage/premium_store.dart';
import '../../core/links.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsStore>();
    final premium = context.watch<PremiumStore>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            title: Text(l10n.settingsTheme),
            subtitle: Text(settings.themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (m) => m == null ? null : settings.setThemeMode(m),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.settingsSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.settingsLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.settingsDark),
                ),
              ],
            ),
          ),

          ListTile(
            title: Text(l10n.settingsLanguage),
            subtitle: Text(settings.languageCode),
            trailing: DropdownButton<String>(
              value: settings.languageCode,
              onChanged: (v) => v == null ? null : settings.setLanguageCode(v),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.settingsLangEnglish),
                ),
                DropdownMenuItem(
                  value: 'de',
                  child: Text(l10n.settingsLangGerman),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text(l10n.settingsLangSpanish),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(l10n.settingsLangFrench),
                ),
                DropdownMenuItem(
                  value: 'it',
                  child: Text(l10n.settingsLangItalian),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.bug_report_rounded),
            title: Text(l10n.settingsReportBug),
            subtitle: Text(l10n.settingsRequiresGithub),
            onTap: openBugReport,
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_rounded),
            title: Text(l10n.settingsSuggestFeature),
            subtitle: Text(l10n.settingsRequiresGithub),
            onTap: openFeatureRequest,
          ),
          ListTile(
            leading: const Icon(Icons.coffee_rounded),
            title: Text(l10n.settingsSupportPicksy),
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
            title: Text(l10n.settingsPrivacyPolicy),
            onTap: () {
              openPrivacyPolicy();
            },
          ),

          const SizedBox(height: 16),

          // Optional: kleine Info
          Text(
            premium.isPro ? l10n.settingsProActive : l10n.settingsFreeVersion,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
