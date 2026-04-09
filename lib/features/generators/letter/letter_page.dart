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

  String? _last;

  final Set<String> _excluded = {};
  bool _noRepeatCycle = false;
  final List<String> _remainingCycle = [];
  final List<String> _usedInCycle = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.letter.accentColor;

    final isProNoRepeat = gate.canUse(ProFeature.letterFilters);

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

          GeneratorSectionTitle(l10n.letterSectionFilters),
          const SizedBox(height: 8),

          // Exclude letters (Pro)
          ListTile(
            title: Text(l10n.letterExcludeLetters),
            subtitle: Text(
              gate.isPro
                  ? (_excluded.isEmpty
                        ? l10n.letterExcludeNone
                        : _excluded.join(', '))
                  : l10n.commonProFeature,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (!gate.isPro) {
                await _showProFiltersDialog(context);
                return;
              }
              await _openExcludeDialog(context);
            },
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: GeneratorType.letter.accentColor,
            title: const Text('No Repeat Until Cycle Complete'),
            subtitle: Text(
              isProNoRepeat
                  ? 'Each letter appears once before reset.'
                  : l10n.commonProFeature,
            ),
            value: _noRepeatCycle,
            onChanged: (v) async {
              if (!isProNoRepeat) {
                await _showProFiltersDialog(context);
                return;
              }
              setState(() {
                _noRepeatCycle = v;
                _remainingCycle.clear();
                _usedInCycle.clear();
              });
            },
          ),

          if (_noRepeatCycle && _usedInCycle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Used letters',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in _usedInCycle)
                  Chip(
                    label: Text(c),
                    backgroundColor: GeneratorType.letter.accentColor
                        .withOpacity(0.15),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.proCard(),
              child: Text(l10n.letterFreeProHint, style: AppStyles.resultStyle),
            ),

          const SizedBox(height: 16),

          FilledButton.icon(
            style: AppStyles.generatorButton(GeneratorType.letter.accentColor),
            icon: const Icon(Icons.casino),
            label: Text(l10n.commonGenerate),
            onPressed: _generate,
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
    final basePool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final pool = basePool.where((c) => !_excluded.contains(c)).toList();
    final effectivePool = pool.isEmpty ? basePool : pool;

    if (!_noRepeatCycle) {
      return effectivePool[_rng.nextInt(effectivePool.length)];
    }

    if (_remainingCycle.isEmpty) {
      _remainingCycle
        ..clear()
        ..addAll(effectivePool);
      _remainingCycle.shuffle(_rng);
      _usedInCycle.clear();
    }

    final next = _remainingCycle.removeLast();
    if (!_usedInCycle.contains(next)) {
      _usedInCycle.add(next);
    }
    return next;
  }

  Future<void> _showProFiltersDialog(BuildContext context) async {
    final l10n = context.l10n;
    await showProDialog(
      context,
      title: l10n.letterFiltersProTitle,
      message: l10n.letterFiltersProMessage,
      generatorType: GeneratorType.letter,
      featureDefinitions: [
        l10n.letterExcludeLetters,
        'No Repeat Until Cycle Complete',
        l10n.letterFiltersProMessage,
      ],
    );
  }

  Future<void> _openExcludeDialog(BuildContext context) async {
    final candidates = <String>{...('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''))};

    final sorted = candidates.toList()..sort((a, b) => a.compareTo(b));

    await showDialog(
      context: context,
      builder: (_) {
        final temp = Set<String>.from(_excluded);
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
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
                        selectedColor: GeneratorType.letter.accentColor
                            .withOpacity(0.2),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    setLocal(() => temp.clear());
                  },
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
            );
          },
        );
      },
    );
  }
}
