import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

enum NumberParity { any }

class NumberPage extends StatefulWidget {
  const NumberPage({super.key});

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  final _rng = Random();

  // Free defaults:
  double _min = 0;
  double _max = 100;

  final NumberParity _parity = NumberParity.any;

  String? _last;

  // helpers
  bool get _isValidRange => _max >= _min;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate; // watch premium changes automatically
    final history = context.read<HistoryStore>();
    final proDefinitions = [
      l10n.numberCustomRangeProMessage,
      l10n.numberParityProMessage,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.numberTitle),
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
                      generatorType: GeneratorType.number,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.number,
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
              GeneratorType.number.accentColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _last ?? l10n.numberTapGenerate,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Range settings
          _SectionTitle(l10n.numberSectionRange),

          const SizedBox(height: 8),

          _RangeRow(
            min: _min,
            max: _max,
            isPro: gate.isPro,
            onChanged: (newMin, newMax) async {
              // Custom range is Pro-only, but Free has fixed 0..100.
              if (!gate.canUse(ProFeature.numberCustomRange)) {
                // reset back to free range
                setState(() {
                  _min = 0;
                  _max = 100;
                });

                await showProDialog(
                  context,
                  title: l10n.numberCustomRangeProTitle,
                  message: l10n.numberCustomRangeProMessage,
                  generatorType: GeneratorType.number,
                  featureDefinitions: proDefinitions,
                );
                return;
              }

              setState(() {
                _min = newMin;
                _max = newMax;
              });
            },
          ),

          if (!_isValidRange) ...[
            const SizedBox(height: 8),
            Text(
              l10n.numberInvalidRange,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 24),

          // Free hint
          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.proCard(),
              child: Text(l10n.numberFreeProHint, style: AppStyles.resultStyle),
            ),

          const SizedBox(height: 16),

          // Generate button (bottom)
          FilledButton.icon(
            style: AppStyles.generatorButton(GeneratorType.number.accentColor),
            onPressed: !_isValidRange
                ? null
                : () async {
                    final value = _generateNumber(
                      min: gate.isPro ? _min : 0,
                      max: gate.isPro ? _max : 100,
                      parity: gate.isPro ? _parity : NumberParity.any,
                    );

                    setState(() => _last = value);

                    await history.add(
                      type: GeneratorType.number,
                      value: value,
                      maxEntries: context.gateRead.historyMax,
                      metadata: {
                        'min': gate.isPro ? _min : 0,
                        'max': gate.isPro ? _max : 100,
                      },
                    );
                  },
            icon: const Icon(Icons.casino),
            label: Text(l10n.commonGenerate),
          ),
        ],
      ),
    );
  }

  String _generateNumber({
    required double min,
    required double max,
    required NumberParity parity,
  }) {
    final minInt = min.floor();
    final maxInt = max.floor();

    // guard if same
    if (maxInt <= minInt) {
      return minInt.toString();
    }

    int candidate() => minInt + _rng.nextInt((maxInt - minInt) + 1);

    int n = candidate();

    if (parity == NumberParity.any) return n.toString();

    for (int i = 0; i < 50; i++) {
      n = candidate();
    }

    n = n.clamp(minInt, maxInt);
    return n.toString();
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

class _RangeRow extends StatelessWidget {
  final double min;
  final double max;
  final bool isPro;
  final Future<void> Function(double newMin, double newMax) onChanged;

  const _RangeRow({
    required this.min,
    required this.max,
    required this.isPro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // For Free, show locked range.
    if (!isPro) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async => onChanged(0, 100),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _LockedField(label: l10n.numberMin, value: '0'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LockedField(label: l10n.numberMax, value: '100'),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _NumberField(
            label: l10n.numberMin,
            initial: min,
            onSubmitted: (v) => onChanged(v, max),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NumberField(
            label: l10n.numberMax,
            initial: max,
            onSubmitted: (v) => onChanged(min, v),
          ),
        ),
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  final String label;
  final String value;
  const _LockedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double initial;
  final ValueChanged<double> onSubmitted;

  const _NumberField({
    required this.label,
    required this.initial,
    required this.onSubmitted,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _ctrl.text = widget.initial.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (txt) {
        final v = double.tryParse(txt.replaceAll(',', '.'));
        if (v == null) return;
        widget.onSubmitted(v);
      },
    );
  }
}
