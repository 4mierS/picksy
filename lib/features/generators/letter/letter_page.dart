import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_styles.dart';

import '../../../core/gating/feature_gate.dart';
import '../../../models/generator_type.dart';
import '../../../storage/history_store.dart';

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

  @override
  Widget build(BuildContext context) {
    final gate = context.gate;
    final history = context.read<HistoryStore>();

    final isProFilters = gate.canUse(ProFeature.letterFilters);

    return Scaffold(
      appBar: AppBar(title: const Text('Letter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Result
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _last ?? 'Tap "Generate" to get a letter',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy',
                  onPressed: _last == null
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: _last!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied')),
                          );
                        },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.casino),
            label: const Text('Generate'),
            onPressed: () async {
              final letter = _generateLetter(isProFilters: isProFilters);
              setState(() => _last = letter);

              await history.add(
                type: GeneratorType.letter,
                value: letter,
                maxEntries: context.gateRead.historyMax,
              );
            },
          ),

          const SizedBox(height: 24),

          _SectionTitle('Filters'),
          const SizedBox(height: 8),

          // Upper/lower toggles (Pro)
          _ProSwitch(
            title: 'Uppercase',
            subtitle: 'Include A–Z',
            value: _upper,
            enabled: isProFilters,
            onChanged: (v) async {
              if (!isProFilters) {
                await _showProFiltersDialog(context);
                return;
              }
              setState(() => _upper = v);
            },
          ),

          _ProSwitch(
            title: 'Lowercase',
            subtitle: 'Include a–z',
            value: _lower,
            enabled: isProFilters,
            onChanged: (v) async {
              if (!isProFilters) {
                await _showProFiltersDialog(context);
                return;
              }
              setState(() => _lower = v);
            },
          ),

          const SizedBox(height: 8),

          _ProSwitch(
            title: 'Include umlauts',
            subtitle: 'Add ä, ö, ü (and Ä, Ö, Ü if uppercase enabled)',
            value: _includeUmlauts,
            enabled: isProFilters,
            onChanged: (v) async {
              if (!isProFilters) {
                await _showProFiltersDialog(context);
                return;
              }
              setState(() => _includeUmlauts = v);
            },
          ),

          _ProSwitch(
            title: 'Only vowels',
            subtitle:
                'Limit selection to vowels (A E I O U + optional umlauts)',
            value: _onlyVowels,
            enabled: isProFilters,
            onChanged: (v) async {
              if (!isProFilters) {
                await _showProFiltersDialog(context);
                return;
              }
              setState(() => _onlyVowels = v);
            },
          ),

          const SizedBox(height: 16),

          // Exclude letters (Pro)
          ListTile(
            title: const Text('Exclude letters'),
            subtitle: Text(
              isProFilters
                  ? (_excluded.isEmpty ? 'None' : _excluded.join(', '))
                  : 'Pro feature',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (!isProFilters) {
                await _showProFiltersDialog(context);
                return;
              }
              await _openExcludeDialog(context);
            },
          ),

          const SizedBox(height: 24),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.glassCard(context),
              child: Text(
                'Free: Random A–Z uppercase.\nPro: lowercase, umlauts, vowels-only, exclude letters.',
                style: AppStyles.resultStyle,
              ),
            ),
        ],
      ),
    );
  }

  String _generateLetter({required bool isProFilters}) {
    // Free mode: A–Z uppercase
    if (!isProFilters) {
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      return letters[_rng.nextInt(letters.length)];
    }

    // Pro mode: build allowed set
    final List<String> pool = [];

    // Base alphabets
    const upperAZ = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const loweraz = 'abcdefghijklmnopqrstuvwxyz';

    // Vowels sets
    const upperVowels = 'AEIOU';
    const lowerVowels = 'aeiou';

    if (_upper) {
      pool.addAll((_onlyVowels ? upperVowels : upperAZ).split(''));
      if (_includeUmlauts) {
        pool.addAll(['Ä', 'Ö', 'Ü']);
      }
    }

    if (_lower) {
      pool.addAll((_onlyVowels ? lowerVowels : loweraz).split(''));
      if (_includeUmlauts) {
        pool.addAll(['ä', 'ö', 'ü']);
      }
    }

    // If user disables both upper and lower, fallback to uppercase
    if (pool.isEmpty) {
      pool.addAll((_onlyVowels ? upperVowels : upperAZ).split(''));
      if (_includeUmlauts) pool.addAll(['Ä', 'Ö', 'Ü']);
    }

    // Apply exclusions
    final filtered = pool.where((c) => !_excluded.contains(c)).toList();
    final finalPool = filtered.isNotEmpty ? filtered : pool;

    return finalPool[_rng.nextInt(finalPool.length)];
  }

  Future<void> _showProFiltersDialog(BuildContext context) async {
    await showProDialog(
      context,
      title: 'Letter filters are Pro',
      message:
          'Go Pro to unlock lowercase, umlauts, vowels-only, and exclusions.',
    );
  }

  Future<void> _openExcludeDialog(BuildContext context) async {
    // Provide candidates based on current casing settings
    final candidates = <String>{};

    if (_upper) candidates.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    if (_lower) candidates.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
    if (_includeUmlauts) {
      if (_upper) candidates.addAll(['Ä', 'Ö', 'Ü']);
      if (_lower) candidates.addAll(['ä', 'ö', 'ü']);
    }

    // Fallback candidates if empty
    if (candidates.isEmpty) {
      candidates.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    }

    final sorted = candidates.toList()..sort((a, b) => a.compareTo(b));

    await showDialog(
      context: context,
      builder: (_) {
        final temp = Set<String>.from(_excluded);

        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Exclude letters'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setLocal(() => temp.clear());
                  },
                  child: const Text('Clear'),
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _ProSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ProSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(enabled ? subtitle : 'Pro feature'),
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }
}
