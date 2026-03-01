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

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  final _rng = Random();

  String? _last;

  // Pro-only
  final _labelA = TextEditingController();
  final _labelB = TextEditingController();

  @override
  void dispose() {
    _labelA.dispose();
    _labelB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_labelA.text.isEmpty) _labelA.text = l10n.coinDefaultHeads;
    if (_labelB.text.isEmpty) _labelB.text = l10n.coinDefaultTails;
    final gate = context.gate;
    final history = context.read<HistoryStore>();

    final canCustomLabels = gate.canUse(ProFeature.coinCustomLabels);

    final currentA = canCustomLabels
        ? _labelA.text.trim()
        : l10n.coinDefaultHeads;
    final currentB = canCustomLabels
        ? _labelB.text.trim()
        : l10n.coinDefaultTails;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coinTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Result card
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.generatorResultCard(
              GeneratorType.coin.accentColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _last ?? l10n.coinTapFlip,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
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

          const SizedBox(height: 16),

          FilledButton.icon(
            style: AppStyles.generatorButton(GeneratorType.coin.accentColor),
            icon: const Icon(Icons.casino),
            label: Text(l10n.coinFlip),
            onPressed: () async {
              final result = (_rng.nextBool() ? currentA : currentB);
              setState(() => _last = result);

              await history.add(
                type: GeneratorType.coin,
                value: result,
                maxEntries: context.gateRead.historyMax,
              );
            },
          ),

          const SizedBox(height: 24),

          _SectionTitle(l10n.coinSectionLabels),
          const SizedBox(height: 8),

          // Pro-only label inputs
          TextField(
            controller: _labelA,
            enabled: canCustomLabels,
            decoration: InputDecoration(
              labelText: l10n.coinOptionA,
              hintText: l10n.coinHintA,
              suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
            ),
            onTap: () async {
              if (!canCustomLabels) {
                await showProDialog(
                  context,
                  title: l10n.coinCustomLabelsProTitle,
                  message: l10n.coinCustomLabelsProMessage,
                );
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _labelB,
            enabled: canCustomLabels,
            decoration: InputDecoration(
              labelText: l10n.coinOptionB,
              hintText: l10n.coinHintB,
              suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
            ),
            onTap: () async {
              if (!canCustomLabels) {
                await showProDialog(
                  context,
                  title: l10n.coinCustomLabelsProTitle,
                  message: l10n.coinCustomLabelsProMessage,
                );
              }
            },
          ),

          const SizedBox(height: 16),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.proCard(),
              child: Text(l10n.coinFreeProHint, style: AppStyles.resultStyle),
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
