import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
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
    'A',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
  ];
  static const _suits = ['♠', '♥', '♦', '♣'];
  static const _suitNames = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];

  List<String>? _lastDrawn;
  bool _includeJokers = false;
  int _multiCount = 1;
  bool _withoutReplacement = false;
  List<String> _deck = [];
  bool _deckHasJokers = false;

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

  void _ensureDeck({required bool withJokers}) {
    if (_deck.isNotEmpty && _deckHasJokers == withJokers) return;
    _deckHasJokers = withJokers;
    _deck = [
      for (int s = 0; s < _suits.length; s++)
        for (final rank in _ranks) '$rank ${_suits[s]}',
      if (withJokers) '🃏 Joker (Red)',
      if (withJokers) '🃏 Joker (Black)',
    ];
  }

  String _drawFromDeck({required bool withJokers}) {
    _ensureDeck(withJokers: withJokers);
    if (_deck.isEmpty) {
      _ensureDeck(withJokers: withJokers);
    }
    final idx = _rng.nextInt(_deck.length);
    final card = _deck.removeAt(idx);
    if (_deck.isEmpty) {
      _ensureDeck(withJokers: withJokers);
    }
    return card;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final history = context.read<HistoryStore>();
    final accent = GeneratorType.card.accentColor;
    final canJokers = gate.canUse(ProFeature.cardJokers);
    final canMultiDraw = gate.canUse(ProFeature.cardMultiDraw);

    final effectiveJokers = canJokers && _includeJokers;
    final effectiveCount = canMultiDraw ? _multiCount : 1;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _lastDrawn == null
                      ? Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 160),
                          decoration: AppStyles.generatorResultCard(
                            GeneratorType.card.accentColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.cardTapDraw,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final card in _lastDrawn!) _PlayingCard(card),
                          ],
                        ),
                ),
              ),

              _SectionTitle(l10n.cardSectionOptions),
              const SizedBox(height: 8),

              // Include Jokers toggle (Pro)
              SwitchListTile(
                activeColor: GeneratorType.card.accentColor,
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

              SwitchListTile(
                activeColor: GeneratorType.card.accentColor,
                title: const Text('Draw Without Replacement'),
                subtitle: const Text(
                  'Drawn cards are removed until deck resets automatically.',
                ),
                value: _withoutReplacement,
                onChanged: (v) => setState(() {
                  _withoutReplacement = v;
                  _deck.clear();
                }),
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
                  child: Text(
                    l10n.cardFreeProHint,
                    style: AppStyles.resultStyle,
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: AppStyles.generatorButton(
                    GeneratorType.card.accentColor,
                  ),
                  icon: const Icon(Icons.style_outlined),
                  label: Text(l10n.cardDraw),
                  onPressed: () async {
                    final drawn = <String>[
                      for (int i = 0; i < effectiveCount; i++)
                        _withoutReplacement
                            ? _drawFromDeck(withJokers: effectiveJokers)
                            : _drawCard(withJokers: effectiveJokers),
                    ];
                    final result = drawn.join(', ');
                    setState(() => _lastDrawn = drawn);

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
                        'withoutReplacement': _withoutReplacement,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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

class _PlayingCard extends StatelessWidget {
  final String raw;
  const _PlayingCard(this.raw);

  @override
  Widget build(BuildContext context) {
    final parts = raw.split(' ');
    final rank = parts.isNotEmpty ? parts.first : raw;
    final suit = parts.length > 1 ? parts[1] : '';
    final isRed = suit == '♥' || suit == '♦';
    final color = isRed ? Colors.red : Colors.black;

    return Container(
      width: 110,
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '$rank$suit',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '$rank$suit',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: color,
              ),
            ),
          ),
        ],
      ),
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
