import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

class LetterPage extends StatefulWidget {
  const LetterPage({super.key});

  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> {
  final _rng = Random();
  late String _last;
  final Set<String> _excluded = {};

  @override
  void initState() {
    super.initState();
    _last = _generateLetter();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.letter.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.letterTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.analyticsTitle,
            onPressed: () {
              if (gate.canUse(ProFeature.analyticsAccess)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GeneratorAnalyticsPage(
                      generatorType: GeneratorType.letter,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.letter,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _last,
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExcludeFilter(
                  excluded: _excluded,
                  isPro: gate.isPro,
                  accent: accent,
                  onTap: () async {
                    if (!gate.isPro) {
                      await showProDialog(
                        context,
                        title: l10n.letterFiltersProTitle,
                        message: l10n.letterFiltersProMessage,
                        generatorType: GeneratorType.letter,
                        featureDefinitions: [l10n.letterExcludeLetters],
                      );
                      return;
                    }
                    await _openExcludeSheet(context);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: AppStyles.generatorButton(accent),
                  icon: const Icon(Icons.casino),
                  label: Text(l10n.commonGenerate),
                  onPressed: _generate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final letter = _generateLetter();
    setState(() => _last = letter);
    await context.read<HistoryStore>().add(
      type: GeneratorType.letter,
      value: letter,
      maxEntries: context.gateRead.historyMax,
      metadata: {'letter': letter},
    );
  }

  String _generateLetter() {
    final base = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final pool = base.where((c) => !_excluded.contains(c)).toList();
    final effective = pool.isEmpty ? base : pool;
    return effective[_rng.nextInt(effective.length)];
  }

  Future<void> _openExcludeSheet(BuildContext context) async {
    final l10n = context.l10n;
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final temp = Set<String>.from(_excluded);
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.letterExcludeLetters,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in letters)
                        FilterChip(
                          label: Text(
                            c,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          selectedColor: GeneratorType.letter.accentColor
                              .withOpacity(0.2),
                          checkmarkColor: GeneratorType.letter.accentColor,
                          selected: temp.contains(c),
                          onSelected: (selected) {
                            setLocal(() {
                              if (selected) {
                                temp.add(c);
                              } else {
                                temp.remove(c);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setLocal(() => temp.clear()),
                        child: Text(l10n.commonClear),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: AppStyles.generatorButton(
                          GeneratorType.letter.accentColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _excluded
                              ..clear()
                              ..addAll(temp);
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Text(l10n.commonSave),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ExcludeFilter extends StatelessWidget {
  final Set<String> excluded;
  final bool isPro;
  final Color accent;
  final VoidCallback onTap;

  const _ExcludeFilter({
    required this.excluded,
    required this.isPro,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = isPro
        ? (excluded.isEmpty
              ? l10n.letterExcludeNone
              : (excluded.toList()..sort()).join(', '))
        : l10n.commonProFeature;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.4)),
          color: accent.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.letterExcludeLetters,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: accent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accent.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
