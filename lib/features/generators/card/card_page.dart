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
  static const _cardCounts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

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
        child: Column(
          children: [
            // ── Drawn cards area (scrollable, takes all spare space) ──────────
            Expanded(
              child: _lastDrawn == null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 160),
                          decoration: AppStyles.generatorResultCard(accent),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.cardTitle,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.cardTapDraw,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final card in _lastDrawn!) _PlayingCard(card),
                        ],
                      ),
                    ),
            ),

            // ── Sticky bottom controls ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Include Jokers toggle
                  _ToggleRow(
                    label: l10n.cardIncludeJokers,
                    value: effectiveJokers,
                    accent: accent,
                    isLocked: !canJokers,
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

                  const SizedBox(height: 10),

                  // Draw Without Replacement toggle
                  _ToggleRow(
                    label: 'Without Replacement',
                    value: _withoutReplacement,
                    accent: accent,
                    onChanged: (v) => setState(() {
                      _withoutReplacement = v;
                      _deck.clear();
                    }),
                  ),

                  const SizedBox(height: 10),

                  // Cards per draw selector
                  Row(
                    children: [
                      GeneratorSectionTitle(l10n.cardMultiDrawCount),
                      if (!canMultiDraw) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.proPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.proPurple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cardCounts.map((count) {
                      final selected = effectiveCount == count;
                      final isLocked = !canMultiDraw && count > 1;
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 32 - 8 * 4) / 5,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: selected
                                ? accent
                                : (isLocked ? AppColors.proPurple : null),
                            side: BorderSide(
                              color: selected
                                  ? accent
                                  : (isLocked
                                        ? AppColors.proPurple.withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.4)),
                              width: selected ? 2 : 1,
                            ),
                            backgroundColor:
                                selected ? accent.withOpacity(0.1) : null,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () async {
                            if (isLocked) {
                              await showProDialog(
                                context,
                                title: l10n.cardMultiDrawProTitle,
                                message: l10n.cardMultiDrawProMessage,
                                generatorType: GeneratorType.card,
                              );
                              return;
                            }
                            setState(() => _multiCount = count);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLocked) ...[
                                Icon(
                                  Icons.lock_outline,
                                  size: 11,
                                  color: AppColors.proPurple,
                                ),
                                const SizedBox(width: 3),
                              ],
                              Text('$count', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Draw button
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
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

                      final firstParts = drawn.first.split(' ');
                      final rank =
                          firstParts.isNotEmpty ? firstParts[0] : '';
                      final suit =
                          firstParts.length > 1 ? firstParts[1] : '';
                      final suitIdx = _suits.indexOf(suit);
                      final suitName =
                          suitIdx >= 0 ? _suitNames[suitIdx] : suit;

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color accent;
  final bool isLocked;
  final void Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GeneratorSectionTitle(label),
            if (isLocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.proPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.proPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: !value ? accent : null,
                  side: BorderSide(
                    color: !value ? accent : Colors.grey.withOpacity(0.4),
                    width: !value ? 2 : 1,
                  ),
                  backgroundColor: !value ? accent.withOpacity(0.1) : null,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => onChanged(false),
                child: const Text('Off'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: value ? accent : null,
                  side: BorderSide(
                    color: value ? accent : Colors.grey.withOpacity(0.4),
                    width: value ? 2 : 1,
                  ),
                  backgroundColor: value ? accent.withOpacity(0.1) : null,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => onChanged(true),
                child: const Text('On'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Playing Card ─────────────────────────────────────────────────────────────

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
