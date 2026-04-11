import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../storage/settings_store.dart';
import '../../storage/premium_store.dart';
import '../../core/links.dart';
import '../../core/ui/app_colors.dart';
import '../pro/compare_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsStore>();
    final premium = context.watch<PremiumStore>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Pro banner (if active) ─────────────────────────────────────
          if (premium.isPro) ...[
            _ProBanner(l10n: l10n),
            const SizedBox(height: 16),
          ],

          // ── Appearance ─────────────────────────────────────────────────
          _SectionLabel(l10n.settingsAppearance),
          Card(
            child: Column(
              children: [
                _DropdownTile<ThemeMode>(
                  icon: Icons.brightness_6_rounded,
                  label: l10n.settingsTheme,
                  value: settings.themeMode,
                  items: [
                    (ThemeMode.system, l10n.settingsSystem),
                    (ThemeMode.light, l10n.settingsLight),
                    (ThemeMode.dark, l10n.settingsDark),
                  ],
                  onChanged: (m) => settings.setThemeMode(m),
                ),
                const Divider(height: 1, indent: 56),
                _DropdownTile<String>(
                  icon: Icons.language_rounded,
                  label: l10n.settingsLanguage,
                  value: settings.languageCode,
                  items: [
                    ('en', l10n.settingsLangEnglish),
                    ('de', l10n.settingsLangGerman),
                    ('es', l10n.settingsLangSpanish),
                    ('fr', l10n.settingsLangFrench),
                    ('it', l10n.settingsLangItalian),
                  ],
                  onChanged: (v) => settings.setLanguageCode(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Feedback ───────────────────────────────────────────────────
          _SectionLabel(l10n.settingsFeedback),
          Card(
            child: Column(
              children: [
                _Tile(
                  icon: Icons.bug_report_rounded,
                  label: l10n.settingsReportBug,
                  subtitle: l10n.settingsRequiresGithub,
                  onTap: openBugReport,
                ),
                const Divider(height: 1, indent: 56),
                _Tile(
                  icon: Icons.lightbulb_rounded,
                  label: l10n.settingsSuggestFeature,
                  subtitle: l10n.settingsRequiresGithub,
                  onTap: openFeatureRequest,
                ),
                const Divider(height: 1, indent: 56),
                _Tile(
                  icon: Icons.coffee_rounded,
                  label: l10n.settingsSupportPicksy,
                  onTap: openCoffee,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── App Store ──────────────────────────────────────────────────
          _SectionLabel(l10n.settingsAppStore),
          Card(
            child: Column(
              children: [
                _Tile(
                  icon: Icons.star_rate_rounded,
                  label: l10n.settingsRateApp,
                  onTap: openRateApp,
                ),
                const Divider(height: 1, indent: 56),
                _Tile(
                  icon: Icons.share_rounded,
                  label: l10n.settingsShareApp,
                  subtitle: l10n.settingsShareAppSubtitle,
                  onTap: shareApp,
                ),
              ],
            ),
          ),

          // ── Compare Free vs Pro (only for free users) ──────────────────
          if (!premium.isPro) ...[
            const SizedBox(height: 20),
            _SectionLabel(l10n.settingsProSection),
            Card(
              child: _Tile(
                icon: Icons.compare_arrows_rounded,
                label: l10n.settingsCompareFreePro,
                iconColor: AppColors.proPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompareFreePro()),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Legal ──────────────────────────────────────────────────────
          _SectionLabel(l10n.settingsLegal),
          Card(
            child: Column(
              children: [
                _Tile(
                  icon: Icons.privacy_tip_rounded,
                  label: l10n.settingsPrivacyPolicy,
                  onTap: openPrivacyPolicy,
                ),
                const Divider(height: 1, indent: 56),
                _Tile(
                  icon: Icons.article_rounded,
                  label: l10n.settingsImprint,
                  onTap: openImprint,
                ),
                const Divider(height: 1, indent: 56),
                _Tile(
                  icon: Icons.gavel_rounded,
                  label: l10n.settingsTermsOfService,
                  onTap: openTermsOfService,
                ),
              ],
            ),
          ),

          // ── Debug ──────────────────────────────────────────────────────
          if (kDebugMode) ...[
            const SizedBox(height: 20),
            _SectionLabel('Debug'),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.science_rounded),
                title: const Text('Toggle Pro'),
                subtitle: Text(premium.isPro ? 'Pro ON' : 'Pro OFF'),
                value: premium.isPro,
                onChanged: (_) => context.read<PremiumStore>().toggleDebugPro(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pro banner ────────────────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  final dynamic l10n;
  const _ProBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFAB47BC)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.settingsProActive,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

// ── Dropdown tile ─────────────────────────────────────────────────────────────

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        onChanged: (v) => v != null ? onChanged(v) : null,
        items: items
            .map((e) => DropdownMenuItem<T>(value: e.$1, child: Text(e.$2)))
            .toList(),
      ),
    );
  }
}
