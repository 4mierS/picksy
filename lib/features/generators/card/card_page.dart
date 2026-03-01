import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final _rng = Random();

  static const _ranks = [
    'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K',
  ];
  static const _suits = ['♠', '♥', '♦', '♣'];
  static const _suitNames = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];

  String? _last;
  bool _includeJokers = false;
  int _multiCount = 1;

  String _drawCard({required bool withJokers}) {
    final pool = <String>[
      for (int s = 0; s < _suits.length; s++)
        for (final rank in _ranks) '$rank ${_suits[s]}',
    ];
    if (withJokers) {
      pool.addAll(['🃏 Joker (Red)', '🃏 Joker (Black)']);
    }
    return pool[_rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final history = context.read<HistoryStore>();

    final canJokers = gate.canUse(ProFeature.cardJokers);
    final canMultiDraw = gate.canUse(ProFeature.cardMultiDraw);

    final effectiveJokers = canJokers && _includeJokers;
    final effectiveCount = canMultiDraw ? _multiCount : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cardTitle),
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
                      generatorType: GeneratorType.card,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.card,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Result card
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.generatorResultCard(
              GeneratorType.card.accentColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _last ?? l10n.cardTapDraw,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                    semanticsLabel: _last == null
                        ? l10n.cardTapDraw
                        : _cardSemanticLabel(_last!),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonCopy,
                  onPressed: _last == null
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: _last!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.commonCopied)),
                          );
                        },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SectionTitle(l10n.cardSectionOptions),
          const SizedBox(height: 8),

          // Include Jokers toggle (Pro)
          SwitchListTile(
            title: Text(l10n.cardIncludeJokers),
            subtitle: Text(l10n.cardIncludeJokersSubtitle),
            value: effectiveJokers,
            secondary: canJokers ? null : const Icon(Icons.lock),
            onChanged: (v) async {
              if (!canJokers) {
                await showProDialog(
                  context,
                  title: l10n.cardIncludeJokersProTitle,
                  message: l10n.cardIncludeJokersProMessage,
                  generatorType: GeneratorType.card,
                );
                return;
              }
              setState(() => _includeJokers = v);
            },
          ),

          // Multi-draw (Pro)
          ListTile(
            title: Text(l10n.cardMultiDrawCount),
            subtitle: Text('$effectiveCount'),
            trailing: canMultiDraw ? null : const Icon(Icons.lock),
            onTap: canMultiDraw
                ? null
                : () async {
                    await showProDialog(
                      context,
                      title: l10n.cardMultiDrawProTitle,
                      message: l10n.cardMultiDrawProMessage,
                      generatorType: GeneratorType.card,
                    );
                  },
          ),
          if (canMultiDraw)
            Slider(
              value: _multiCount.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_multiCount',
              activeColor: GeneratorType.card.accentColor,
              onChanged: (v) => setState(() => _multiCount = v.round()),
            ),

          const SizedBox(height: 16),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.proCard(),
              child: Text(l10n.cardFreeProHint, style: AppStyles.resultStyle),
            ),

          const SizedBox(height: 16),

          FilledButton.icon(
            style: AppStyles.generatorButton(GeneratorType.card.accentColor),
            icon: const Icon(Icons.style_outlined),
            label: Text(l10n.cardDraw),
            onPressed: () async {
              final drawn = <String>[
                for (int i = 0; i < effectiveCount; i++)
                  _drawCard(withJokers: effectiveJokers),
              ];
              final result = drawn.join(', ');
              setState(() => _last = result);

              // Parse rank and suit from first card for metadata
              final firstParts = drawn.first.split(' ');
              final rank = firstParts.isNotEmpty ? firstParts[0] : '';
              final suit = firstParts.length > 1 ? firstParts[1] : '';
              final suitIdx = _suits.indexOf(suit);
              final suitName = suitIdx >= 0 ? _suitNames[suitIdx] : suit;

              await history.add(
                type: GeneratorType.card,
                value: result,
                maxEntries: context.gateRead.historyMax,
                metadata: {
                  'rank': rank,
                  'suit': suit,
                  'suitName': suitName,
                  if (effectiveCount > 1) 'drawnCount': effectiveCount,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Produces a screen-reader-friendly label for a drawn card string.
  String _cardSemanticLabel(String value) {
    // For multi-draw, just return the value as-is
    if (value.contains(',')) return value;
    final parts = value.split(' ');
    if (parts.length >= 2) {
      final rank = parts[0];
      final suit = parts[1];
      final suitIdx = _suits.indexOf(suit);
      final suitName = suitIdx >= 0 ? _suitNames[suitIdx] : suit;
      return '$rank of $suitName';
    }
    return value;
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
