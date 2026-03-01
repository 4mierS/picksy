import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/app_localizations.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/models/history_entry.dart';
import 'package:picksy/storage/history_store.dart';

import '../auto_run_sheet.dart';

class GeneratorAnalyticsPage extends StatelessWidget {
  final GeneratorType generatorType;

  const GeneratorAnalyticsPage({super.key, required this.generatorType});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final history = context.watch<HistoryStore>();
    final entries = history.forGenerator(generatorType);
    final accent = generatorType.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsGeneratorTitle(generatorType.localizedTitle(context))),
        actions: [
          if (generatorType != GeneratorType.reactionTest &&
              generatorType != GeneratorType.hangman &&
              generatorType != GeneratorType.colorReflex)
            if (gate.canUse(ProFeature.autoRun))
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                tooltip: l10n.analyticsAutoRun,
                onPressed: () {
                  showAutoRunSheet(
                    context,
                    generator: () => _simulateGenerate(generatorType),
                    generatorName: generatorType.localizedTitle(context),
                  );
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                tooltip: l10n.analyticsAutoRun,
                onPressed: () {
                  showProDialog(
                    context,
                    title: l10n.analyticsAutoRun,
                    message: l10n.analyticsProMessage,
                  );
                },
              ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                l10n.analyticsEmpty,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyles.generatorResultCard(accent),
                  child: Row(
                    children: [
                      Icon(generatorType.homeIcon, color: accent, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            generatorType.localizedTitle(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${entries.length} ${l10n.analyticsTotal.toLowerCase()}',
                            style: TextStyle(color: accent, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Generator-specific stats
                _StatsSection(generatorType: generatorType, entries: entries),

                const SizedBox(height: 16),

                // Recent history
                Text(
                  l10n.historyTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final e in entries.take(20))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: accent.withOpacity(0.08),
                        border: Border.all(color: accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(e.timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (entries.length > 20)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${entries.length - 20} more',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Simulate a single generation for auto-run (uses stored distribution).
  String _simulateGenerate(GeneratorType type) {
    final rng = Random();
    switch (type) {
      case GeneratorType.coin:
        return rng.nextBool() ? 'Heads' : 'Tails';
      case GeneratorType.number:
        return (rng.nextInt(101)).toString();
      case GeneratorType.letter:
        const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return letters[rng.nextInt(letters.length)];
      case GeneratorType.color:
        final r = rng.nextInt(256);
        final g = rng.nextInt(256);
        final b = rng.nextInt(256);
        return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
      case GeneratorType.bottleSpin:
        return '${rng.nextInt(360)}°';
      case GeneratorType.time:
        final ms = 3000 + rng.nextInt(9001);
        return '${ms ~/ 1000}s ${ms % 1000}ms';
      case GeneratorType.reactionTest:
        return '${150 + rng.nextInt(500)} ms';
      case GeneratorType.hangman:
        return rng.nextBool() ? 'Won' : 'Lost';
      case GeneratorType.customList:
        return 'Item ${rng.nextInt(10) + 1}';
      case GeneratorType.colorReflex:
        final correct = rng.nextInt(30);
        final total = correct + rng.nextInt(15);
        final pct = total > 0 ? (correct / total * 100) : 0.0;
        return '$correct/$total (${pct.toStringAsFixed(1)}%)';
    }
  }
}

/// Stats section that adapts to each generator type.
class _StatsSection extends StatelessWidget {
  final GeneratorType generatorType;
  final List<HistoryEntry> entries;

  const _StatsSection({
    required this.generatorType,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = generatorType.accentColor;

    switch (generatorType) {
      case GeneratorType.coin:
        return _CoinStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.number:
        return _NumberStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.letter:
        return _LetterStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.color:
        return _ColorStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.bottleSpin:
        return _BottleSpinStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.time:
        return _TimeStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.reactionTest:
        return _ReactionStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.hangman:
        return _HangmanStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.customList:
        return _CustomListStats(entries: entries, l10n: l10n, accent: accent);
      case GeneratorType.colorReflex:
        return _ColorReflexStats(entries: entries, l10n: l10n, accent: accent);
    }
  }
}

// ─── Stat Widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accent.withOpacity(0.1),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Widget> children;

  const _StatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Coin ───────────────────────────────────────────────────────────────────

class _CoinStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _CoinStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final values = entries.map((e) => e.value.toLowerCase()).toList();
    final heads = values.where((v) => v.contains('head')).length;
    final tails = values.length - heads;
    final total = values.length;

    final headPct = total > 0 ? heads / total : 0.5;
    final tailPct = total > 0 ? tails / total : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.analyticsFrequency),
        _StatsGrid(
          children: [
            _StatCard(label: 'Heads', value: '$heads (${(headPct * 100).toStringAsFixed(1)}%)', accent: accent),
            _StatCard(label: 'Tails', value: '$tails (${(tailPct * 100).toStringAsFixed(1)}%)', accent: accent),
          ],
        ),
        const SizedBox(height: 12),
        _BarRow(label: 'Heads', fraction: headPct, accent: accent),
        const SizedBox(height: 6),
        _BarRow(label: 'Tails', fraction: tailPct, accent: accent),
      ],
    );
  }
}

// ─── Number ─────────────────────────────────────────────────────────────────

class _NumberStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _NumberStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final nums = entries
        .map((e) => double.tryParse(e.value))
        .whereType<double>()
        .toList();

    if (nums.isEmpty) return const SizedBox.shrink();

    final minVal = nums.reduce(min);
    final maxVal = nums.reduce(max);
    final avg = nums.reduce((a, b) => a + b) / nums.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.analyticsFrequency),
        _StatsGrid(
          children: [
            _StatCard(label: 'Min', value: minVal.toStringAsFixed(nums.any((n) => n != n.roundToDouble()) ? 2 : 0), accent: accent),
            _StatCard(label: 'Max', value: maxVal.toStringAsFixed(nums.any((n) => n != n.roundToDouble()) ? 2 : 0), accent: accent),
            _StatCard(label: 'Avg', value: avg.toStringAsFixed(2), accent: accent),
            _StatCard(label: l10n.analyticsTotal, value: '${nums.length}', accent: accent),
          ],
        ),
      ],
    );
  }
}

// ─── Letter ─────────────────────────────────────────────────────────────────

class _LetterStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _LetterStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final e in entries) {
      freq[e.value] = (freq[e.value] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.analyticsFrequency),
        for (final entry in sorted.take(10)) ...[
          _BarRow(
            label: entry.key,
            fraction: maxVal > 0 ? entry.value / maxVal : 0,
            accent: accent,
            trailing: '${entry.value}',
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

// ─── Color ──────────────────────────────────────────────────────────────────

class _ColorStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _ColorStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final recent = entries.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.analyticsFrequency),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.map((e) {
            final hex = e.value.replaceAll('#', '');
            Color? color;
            try {
              if (hex.length == 6) {
                color = Color(int.parse('FF$hex', radix: 16));
              }
            } catch (_) {}
            return Tooltip(
              message: e.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color ?? Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── BottleSpin ─────────────────────────────────────────────────────────────

class _BottleSpinStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _BottleSpinStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    // Extract degree numbers from "Angle: 123°" format
    final angles = entries.map((e) {
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(e.value);
      return match != null ? double.tryParse(match.group(1)!) : null;
    }).whereType<double>().toList();

    if (angles.isEmpty) return const SizedBox.shrink();

    final avg = angles.reduce((a, b) => a + b) / angles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          children: [
            _StatCard(label: l10n.analyticsTotal, value: '${angles.length}', accent: accent),
            _StatCard(label: 'Avg Angle', value: '${avg.toStringAsFixed(1)}°', accent: accent),
          ],
        ),
      ],
    );
  }
}

// ─── Time ───────────────────────────────────────────────────────────────────

class _TimeStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _TimeStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    // Parse "Xs Yms" or use metadata targetMs
    final ms = entries.map((e) {
      final meta = e.metadata;
      if (meta != null && meta['targetMs'] != null) {
        return (meta['targetMs'] as num).toDouble();
      }
      // Parse "Xs Yms"
      final match = RegExp(r'(\d+)s\s*(\d+)ms').firstMatch(e.value);
      if (match != null) {
        final sec = int.tryParse(match.group(1)!) ?? 0;
        final milli = int.tryParse(match.group(2)!) ?? 0;
        return (sec * 1000 + milli).toDouble();
      }
      return null;
    }).whereType<double>().toList();

    if (ms.isEmpty) return const SizedBox.shrink();

    final minMs = ms.reduce(min);
    final maxMs = ms.reduce(max);
    final avgMs = ms.reduce((a, b) => a + b) / ms.length;

    String fmt(double v) => '${(v / 1000).toStringAsFixed(2)}s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          children: [
            _StatCard(label: 'Min', value: fmt(minMs), accent: accent),
            _StatCard(label: 'Max', value: fmt(maxMs), accent: accent),
            _StatCard(label: l10n.analyticsAvgTime, value: fmt(avgMs), accent: accent),
            _StatCard(label: l10n.analyticsTotal, value: '${ms.length}', accent: accent),
          ],
        ),
      ],
    );
  }
}

// ─── ReactionTest ───────────────────────────────────────────────────────────

class _ReactionStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _ReactionStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tooSoonCount = entries.where((e) => e.value == 'Too soon').length;
    final validEntries = entries.where((e) => e.value != 'Too soon').toList();
    final ms = validEntries.map((e) {
      final meta = e.metadata;
      if (meta != null && meta['ms'] != null) {
        return (meta['ms'] as num).toDouble();
      }
      final match = RegExp(r'(\d+)\s*ms').firstMatch(e.value);
      return match != null ? double.tryParse(match.group(1)!) : null;
    }).whereType<double>().toList();

    if (ms.isEmpty) {
      return _StatsGrid(
        children: [
          _StatCard(label: l10n.analyticsTotal, value: '${entries.length}', accent: accent),
          _StatCard(label: 'Too Soon', value: '$tooSoonCount', accent: Colors.orange),
        ],
      );
    }

    final best = ms.reduce(min);
    final avg = ms.reduce((a, b) => a + b) / ms.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          children: [
            _StatCard(label: l10n.analyticsBestTime, value: '${best.toStringAsFixed(0)} ms', accent: accent),
            _StatCard(label: l10n.analyticsAvgTime, value: '${avg.toStringAsFixed(0)} ms', accent: accent),
            _StatCard(label: l10n.analyticsTotal, value: '${ms.length}', accent: accent),
            _StatCard(label: 'Too Soon', value: '$tooSoonCount', accent: Colors.orange),
          ],
        ),
      ],
    );
  }
}

// ─── Hangman ────────────────────────────────────────────────────────────────

class _HangmanStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _HangmanStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    int wins = 0;
    int losses = 0;
    for (final e in entries) {
      final meta = e.metadata;
      if (meta != null && meta['won'] != null) {
        if (meta['won'] as bool) {
          wins++;
        } else {
          losses++;
        }
      } else if (e.value.toLowerCase().contains('won') ||
          e.value.toLowerCase().startsWith('won')) {
        wins++;
      } else {
        losses++;
      }
    }
    final total = wins + losses;
    final winRate = total > 0 ? wins / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          children: [
            _StatCard(label: l10n.analyticsWins, value: '$wins', accent: accent),
            _StatCard(label: l10n.analyticsLosses, value: '$losses', accent: accent),
            _StatCard(label: l10n.analyticsWinRate, value: '${(winRate * 100).toStringAsFixed(1)}%', accent: accent),
            _StatCard(label: l10n.analyticsTotal, value: '$total', accent: accent),
          ],
        ),
        const SizedBox(height: 12),
        _BarRow(label: l10n.analyticsWins, fraction: winRate, accent: Colors.green),
        const SizedBox(height: 6),
        _BarRow(label: l10n.analyticsLosses, fraction: 1 - winRate, accent: Colors.redAccent),
      ],
    );
  }
}

// ─── CustomList ─────────────────────────────────────────────────────────────

class _CustomListStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _CustomListStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final freq = <String, int>{};
    for (final e in entries) {
      // Only track single-pick entries (not team results)
      final val = e.value;
      if (!val.contains('\n')) {
        freq[val] = (freq[val] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    if (sorted.isEmpty) {
      return _StatCard(
        label: l10n.analyticsTotal,
        value: '${entries.length}',
        accent: accent,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.analyticsFrequency),
        for (final entry in sorted.take(10)) ...[
          _BarRow(
            label: entry.key,
            fraction: maxVal > 0 ? entry.value / maxVal : 0,
            accent: accent,
            trailing: '${entry.value}',
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

// ─── ColorReflex ─────────────────────────────────────────────────────────────

class _ColorReflexStats extends StatelessWidget {
  final List<HistoryEntry> entries;
  final AppLocalizations l10n;
  final Color accent;

  const _ColorReflexStats({
    required this.entries,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final accuracies = <double>[];
    final correctCounts = <int>[];
    final reactionMs = <int>[];

    for (final e in entries) {
      final meta = e.metadata;
      if (meta == null) continue;

      if (meta['accuracy'] != null) {
        accuracies.add((meta['accuracy'] as num).toDouble());
      }
      if (meta['totalCorrect'] != null) {
        correctCounts.add((meta['totalCorrect'] as num).toInt());
      }
      if (meta['avgReactionMs'] != null) {
        final ms = (meta['avgReactionMs'] as num).toInt();
        if (ms > 0) reactionMs.add(ms);
      }
    }

    if (accuracies.isEmpty) {
      return _StatCard(
        label: l10n.analyticsTotal,
        value: '${entries.length}',
        accent: accent,
      );
    }

    final bestAccuracy = accuracies.reduce(max);
    final avgAccuracy =
        accuracies.reduce((a, b) => a + b) / accuracies.length;
    final bestScore =
        correctCounts.isNotEmpty ? correctCounts.reduce(max) : 0;
    final avgReaction =
        reactionMs.isNotEmpty
            ? reactionMs.reduce((a, b) => a + b) ~/ reactionMs.length
            : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(
          children: [
            _StatCard(
              label: l10n.analyticsHighScore,
              value: '$bestScore',
              accent: accent,
            ),
            _StatCard(
              label: l10n.analyticsBestAccuracy,
              value: '${bestAccuracy.toStringAsFixed(1)}%',
              accent: accent,
            ),
            _StatCard(
              label: l10n.analyticsAvgAccuracy,
              value: '${avgAccuracy.toStringAsFixed(1)}%',
              accent: accent,
            ),
            _StatCard(
              label: l10n.analyticsTotal,
              value: '${entries.length}',
              accent: accent,
            ),
          ],
        ),
        if (avgReaction > 0) ...[
          const SizedBox(height: 10),
          _StatCard(
            label: l10n.analyticsAvgTime,
            value: '$avgReaction ms',
            accent: accent,
          ),
        ],
      ],
    );
  }
}

// ─── Bar Row Widget ──────────────────────────────────────────────────────────

class _BarRow extends StatelessWidget {
  final String label;
  final double fraction;
  final Color accent;
  final String? trailing;

  const _BarRow({
    required this.label,
    required this.fraction,
    required this.accent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ],
    );
  }
}
