import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

enum NumberParity { any, even, odd }

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

  bool _useFloat = false;
  NumberParity _parity = NumberParity.any;

  String? _last;

  bool get _isValidRange => _max >= _min;

  Future<void> _generate() async {
    if (!_isValidRange) return;
    final gate = context.gateRead;
    final value = _generateNumber(
      min: gate.isPro ? _min : 0,
      max: gate.isPro ? _max : 100,
      useFloat: gate.isPro && _useFloat,
      parity: gate.isPro ? _parity : NumberParity.any,
    );

    setState(() => _last = value);

    await context.read<HistoryStore>().add(
      type: GeneratorType.number,
      value: value,
      maxEntries: gate.historyMax,
      metadata: {
        'min': gate.isPro ? _min : 0,
        'max': gate.isPro ? _max : 100,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.number.accentColor;

    void openProDialog() => showProDialog(
      context,
      title: l10n.numberCustomRangeProTitle,
      message: l10n.numberCustomRangeProMessage,
      generatorType: GeneratorType.number,
      featureDefinitions: [
        l10n.numberCustomRangeProMessage,
        l10n.numberFloatProMessage,
        l10n.numberParityProMessage,
      ],
    );

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
          // ── Result area (tap to generate) ────────────────────────────────
          ResultDisplayArea(
            accentColor: accent,
            hint: l10n.numberTapGenerate,
            result: _last,
            fontSize: 36,
            onTap: _isValidRange ? _generate : null,
          ),

          if (!_isValidRange) ...[
            const SizedBox(height: 8),
            Text(
              l10n.numberInvalidRange,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 24),

          // ── Pro features ─────────────────────────────────────────────────
          PremiumSection(
            isPro: gate.isPro,
            onProRequired: openProDialog,
            title: l10n.numberSectionRange,
            children: [
              _RangeRow(
                min: _min,
                max: _max,
                onChanged: (newMin, newMax) => setState(() {
                  _min = newMin;
                  _max = newMax;
                }),
              ),

              const SizedBox(height: 16),

              GeneratorSectionTitle(l10n.numberSectionType),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.numberFloat),
                subtitle: Text(l10n.numberFloatSubtitle),
                value: _useFloat,
                onChanged: (v) => setState(() => _useFloat = v),
              ),

              if (!_useFloat) ...[
                const SizedBox(height: 8),
                GeneratorSectionTitle(l10n.numberSectionFilter),
                const SizedBox(height: 8),
                _ParitySelector(
                  value: _parity,
                  onChanged: (p) => setState(() => _parity = p),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _generateNumber({
    required double min,
    required double max,
    required bool useFloat,
    required NumberParity parity,
  }) {
    if (useFloat) {
      final x = min + _rng.nextDouble() * (max - min);
      return x.toStringAsFixed(2);
    }

    final minInt = min.floor();
    final maxInt = max.floor();

    if (maxInt <= minInt) {
      return minInt.toString();
    }

    int candidate() => minInt + _rng.nextInt((maxInt - minInt) + 1);

    int n = candidate();

    if (parity == NumberParity.any) return n.toString();

    for (int i = 0; i < 50; i++) {
      if (parity == NumberParity.even && n.isEven) return n.toString();
      if (parity == NumberParity.odd && n.isOdd) return n.toString();
      n = candidate();
    }

    if (parity == NumberParity.even) {
      if (n.isOdd) n += 1;
      if (n > maxInt) n -= 2;
    } else {
      if (n.isEven) n += 1;
      if (n > maxInt) n -= 2;
    }

    n = n.clamp(minInt, maxInt);
    return n.toString();
  }
}

class _RangeRow extends StatelessWidget {
  final double min;
  final double max;
  final void Function(double newMin, double newMax) onChanged;

  const _RangeRow({
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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

class _ParitySelector extends StatelessWidget {
  final NumberParity value;
  final ValueChanged<NumberParity> onChanged;

  const _ParitySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<NumberParity>(
      segments: [
        ButtonSegment(
          value: NumberParity.any,
          label: Text(l10n.numberParityAny),
        ),
        ButtonSegment(
          value: NumberParity.even,
          label: Text(l10n.numberParityEven),
        ),
        ButtonSegment(
          value: NumberParity.odd,
          label: Text(l10n.numberParityOdd),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
