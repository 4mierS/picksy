import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

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

  String? _last;

  // Pro-only filters
  bool _upper = true;
  bool _lower = false;
  bool _includeUmlauts = false;
  bool _onlyVowels = false;
  final Set<String> _excluded = {};

  Future<void> _generate() async {
    final gate = context.gateRead;
    final isProFilters = gate.canUse(ProFeature.letterFilters);
    final letter = _generateLetter(isProFilters: isProFilters);
    setState(() => _last = letter);

    await context.read<HistoryStore>().add(
      type: GeneratorType.letter,
      value: letter,
      maxEntries: gate.historyMax,
      metadata: {'letter': letter},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.letter.accentColor;

    void openProDialog() => showProDialog(
      context,
      title: l10n.letterFiltersProTitle,
      message: l10n.letterFiltersProMessage,
      generatorType: GeneratorType.letter,
      featureDefinitions: [
        l10n.letterUppercaseSubtitle,
        l10n.letterLowercaseSubtitle,
        l10n.letterIncludeUmlautsSubtitle,
        l10n.letterOnlyVowelsSubtitle,
        l10n.letterFiltersProMessage,
      ],
    );

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Result area (tap to generate) ────────────────────────────────
          ResultDisplayArea(
            accentColor: accent,
            hint: l10n.letterTapGenerate,
            result: _last,
            fontSize: 36,
            textAlign: TextAlign.center,
            onTap: _generate,
          ),

          const SizedBox(height: 24),

          // ── Pro features ─────────────────────────────────────────────────
          PremiumSection(
            isPro: gate.isPro,
            onProRequired: openProDialog,
            title: l10n.letterSectionFilters,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.letterUppercase),
                subtitle: Text(l10n.letterUppercaseSubtitle),
                value: _upper,
                onChanged: (v) => setState(() => _upper = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.letterLowercase),
                subtitle: Text(l10n.letterLowercaseSubtitle),
                value: _lower,
                onChanged: (v) => setState(() => _lower = v),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.letterIncludeUmlauts),
                subtitle: Text(l10n.letterIncludeUmlautsSubtitle),
                value: _includeUmlauts,
                onChanged: (v) => setState(() => _includeUmlauts = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.letterOnlyVowels),
                subtitle: Text(l10n.letterOnlyVowelsSubtitle),
                value: _onlyVowels,
                onChanged: (v) => setState(() => _onlyVowels = v),
              ),

              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.letterExcludeLetters),
                subtitle: Text(
                  _excluded.isEmpty
                      ? l10n.letterExcludeNone
                      : _excluded.join(', '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: gate.isPro
                    ? () => _openExcludeDialog(context)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _generateLetter({required bool isProFilters}) {
    if (!isProFilters) {
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      return letters[_rng.nextInt(letters.length)];
    }

    final List<String> pool = [];
    const upperAZ = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const loweraz = 'abcdefghijklmnopqrstuvwxyz';
    const upperVowels = 'AEIOU';
    const lowerVowels = 'aeiou';

    if (_upper) {
      pool.addAll((_onlyVowels ? upperVowels : upperAZ).split(''));
      if (_includeUmlauts) pool.addAll(['Ä', 'Ö', 'Ü']);
    }
    if (_lower) {
      pool.addAll((_onlyVowels ? lowerVowels : loweraz).split(''));
      if (_includeUmlauts) pool.addAll(['ä', 'ö', 'ü']);
    }
    if (pool.isEmpty) {
      pool.addAll((_onlyVowels ? upperVowels : upperAZ).split(''));
      if (_includeUmlauts) pool.addAll(['Ä', 'Ö', 'Ü']);
    }

    final filtered = pool.where((c) => !_excluded.contains(c)).toList();
    final finalPool = filtered.isNotEmpty ? filtered : pool;
    return finalPool[_rng.nextInt(finalPool.length)];
  }

  Future<void> _openExcludeDialog(BuildContext context) async {
    final candidates = <String>{};
    if (_upper) candidates.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    if (_lower) candidates.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
    if (_includeUmlauts) {
      if (_upper) candidates.addAll(['Ä', 'Ö', 'Ü']);
      if (_lower) candidates.addAll(['ä', 'ö', 'ü']);
    }
    if (candidates.isEmpty) {
      candidates.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    }

    final sorted = candidates.toList()..sort((a, b) => a.compareTo(b));

    await showDialog(
      context: context,
      builder: (_) {
        final temp = Set<String>.from(_excluded);
        return StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: Text(context.l10n.letterExcludeLetters),
            content: SizedBox(
              width: double.maxFinite,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in sorted)
                    FilterChip(
                      label: Text(c),
                      selected: temp.contains(c),
                      onSelected: (sel) => setLocal(() {
                        sel ? temp.add(c) : temp.remove(c);
                      }),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => setLocal(() => temp.clear()),
                child: Text(context.l10n.commonClear),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _excluded
                      ..clear()
                      ..addAll(temp);
                  });
                  Navigator.of(context).pop();
                },
                child: Text(context.l10n.commonSave),
              ),
            ],
          ),
        );
      },
    );
  }
}
