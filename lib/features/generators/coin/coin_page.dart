import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_styles.dart';

import '../../../core/gating/feature_gate.dart';
import '../../../models/generator_type.dart';
import '../../../storage/history_store.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  final _rng = Random();

  String? _last;

  // Pro-only
  final _labelA = TextEditingController(text: 'Heads');
  final _labelB = TextEditingController(text: 'Tails');

  @override
  void dispose() {
    _labelA.dispose();
    _labelB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gate = context.gate;
    final history = context.read<HistoryStore>();

    final canCustomLabels = gate.canUse(ProFeature.coinCustomLabels);

    final currentA = canCustomLabels ? _labelA.text.trim() : 'Heads';
    final currentB = canCustomLabels ? _labelB.text.trim() : 'Tails';

    return Scaffold(
      appBar: AppBar(title: const Text('Coin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Result card
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
                    _last ?? 'Tap "Flip" to get a result',
                    style: const TextStyle(
                      fontSize: 20,
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
            label: const Text('Flip'),
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

          _SectionTitle('Labels'),
          const SizedBox(height: 8),

          // Pro-only label inputs
          TextField(
            controller: _labelA,
            enabled: canCustomLabels,
            decoration: InputDecoration(
              labelText: 'Option A',
              hintText: 'Heads / Yes / True...',
              suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
            ),
            onTap: () async {
              if (!canCustomLabels) {
                await showProDialog(
                  context,
                  title: 'Custom labels are Pro',
                  message:
                      'Go Pro to define your own labels (e.g. Yes/No, True/False).',
                );
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _labelB,
            enabled: canCustomLabels,
            decoration: InputDecoration(
              labelText: 'Option B',
              hintText: 'Tails / No / False...',
              suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
            ),
            onTap: () async {
              if (!canCustomLabels) {
                await showProDialog(
                  context,
                  title: 'Custom labels are Pro',
                  message:
                      'Go Pro to define your own labels (e.g. Yes/No, True/False).',
                );
              }
            },
          ),

          const SizedBox(height: 16),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.glassCard(context),
              child: Text(
                'Free: Heads/Tails.\nPro: Custom labels.',
                style: AppStyles.resultStyle,
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
