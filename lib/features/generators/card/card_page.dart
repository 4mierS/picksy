import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

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

  Future<void> _draw({
    required bool effectiveJokers,
    required int effectiveCount,
  }) async {
    final drawn = <String>[
      for (int i = 0; i < effectiveCount; i++)
        _drawCard(withJokers: effectiveJokers),
    ];
    final result = drawn.join(', ');
    setState(() => _last = result);

    final firstParts = drawn.first.split(' ');
    final rank = firstParts.isNotEmpty ? firstParts[0] : '';
    final suit = firstParts.length > 1 ? firstParts[1] : '';
    final suitIdx = _suits.indexOf(suit);
    final suitName = suitIdx >= 0 ? _suitNames[suitIdx] : suit;

    await context.read<HistoryStore>().add(
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.card.accentColor;

    final effectiveJokers = gate.canUse(ProFeature.cardJokers) && _includeJokers;
    final effectiveCount = gate.canUse(ProFeature.cardMultiDraw) ? _multiCount : 1;

    void openProDialog() => showProDialog(
      context,
      title: l10n.cardIncludeJokersProTitle,
      message: l10n.cardIncludeJokersProMessage,
      generatorType: GeneratorType.card,
      featureDefinitions: [
        l10n.cardIncludeJokersProMessage,
        l10n.cardMultiDrawProMessage,
      ],
    );

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
          // ── Result area (tap to draw) ─────────────────────────────────────
          ResultDisplayArea(
            accentColor: accent,
            hint: l10n.cardTapDraw,
            result: _last,
            fontSize: 28,
            onTap: () => _draw(
              effectiveJokers: effectiveJokers,
              effectiveCount: effectiveCount,
            ),
            trailing: IconButton(
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
          ),

          const SizedBox(height: 24),

          // ── Pro features ─────────────────────────────────────────────────
          PremiumSection(
            isPro: gate.isPro,
            onProRequired: openProDialog,
            title: l10n.cardSectionOptions,
            children: [
              // Include Jokers toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cardIncludeJokers),
                subtitle: Text(l10n.cardIncludeJokersSubtitle),
                value: _includeJokers,
                onChanged: (v) => setState(() => _includeJokers = v),
              ),

              // Multi-draw slider
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cardMultiDrawCount),
                subtitle: Text('$_multiCount'),
              ),
              Slider(
                value: _multiCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_multiCount',
                activeColor: accent,
                onChanged: (v) => setState(() => _multiCount = v.round()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _cardSemanticLabel(String value) {
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
