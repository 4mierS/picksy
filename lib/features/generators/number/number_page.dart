import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_styles.dart';
import '../../../l10n/l10n.dart';

import '../../../core/gating/feature_gate.dart';
import '../../../models/generator_type.dart';
import '../../../storage/history_store.dart';
import 'package:flutter/services.dart';

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

  // helpers
  bool get _isValidRange => _max >= _min;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate; // watch premium changes automatically
    final history = context.read<HistoryStore>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.numberTitle)),
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
                    _last ?? l10n.numberTapGenerate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

          const SizedBox(height: 18),

          // Float toggle
          _SectionTitle(l10n.numberSectionType),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.numberFloat),
            subtitle: Text(
              gate.canUse(ProFeature.numberFloat)
                  ? l10n.numberFloatSubtitle
                  : l10n.commonProFeature,
            ),
            value: _useFloat,
            onChanged: (v) async {
              if (!gate.canUse(ProFeature.numberFloat)) {
                await showProDialog(
                  context,
                  title: l10n.numberFloatProTitle,
                  message: l10n.numberFloatProMessage,
                );
                return;
              }
              setState(() => _useFloat = v);
            },
          ),

          const SizedBox(height: 8),

          // Parity filter
          _SectionTitle(l10n.numberSectionFilter),
          const SizedBox(height: 8),

          _ParitySelector(
            value: _parity,
            enabled: gate.canUse(ProFeature.numberEvenOdd),
            onChanged: (p) async {
              if (!gate.canUse(ProFeature.numberEvenOdd)) {
                await showProDialog(
                  context,
                  title: l10n.numberParityProTitle,
                  message: l10n.numberParityProMessage,
                );
                return;
              }
              setState(() => _parity = p);
            },
          ),

          const SizedBox(height: 24),

          // Generate button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: !_isValidRange
                ? null
                : () async {
                    final value = _generateNumber(
                      min: gate.isPro ? _min : 0,
                      max: gate.isPro ? _max : 100,
                      useFloat: gate.isPro && _useFloat,
                      parity: gate.isPro ? _parity : NumberParity.any,
                    );

                    setState(() => _last = value);

                    await history.add(
                      type: GeneratorType.number,
                      value: value,
                      maxEntries: context.gateRead.historyMax,
                    );
                  },
            icon: const Icon(Icons.casino),
            label: Text(l10n.commonGenerate),
          ),

          const SizedBox(height: 24),

          // Free hint
          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.glassCard(context),
              child: Text(l10n.numberFreeProHint, style: AppStyles.resultStyle),
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

    // guard if same
    if (maxInt <= minInt) {
      return minInt.toString();
    }

    int candidate() => minInt + _rng.nextInt((maxInt - minInt) + 1);

    int n = candidate();

    if (parity == NumberParity.any) return n.toString();

    // try a few times; if range too small, fallback
    for (int i = 0; i < 50; i++) {
      if (parity == NumberParity.even && n.isEven) return n.toString();
      if (parity == NumberParity.odd && n.isOdd) return n.toString();
      n = candidate();
    }

    // fallback: adjust to nearest if possible
    if (parity == NumberParity.even) {
      if (n.isOdd) n += 1;
      if (n > maxInt) n -= 2;
    } else {
      if (n.isEven) n += 1;
      if (n > maxInt) n -= 2;
    }

    // still might be outside; clamp
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
      return Row(
        children: [
          Expanded(
            child: _LockedField(label: l10n.numberMin, value: '0'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LockedField(label: l10n.numberMax, value: '100'),
          ),
        ],
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

class _ParitySelector extends StatelessWidget {
  final NumberParity value;
  final bool enabled;
  final ValueChanged<NumberParity> onChanged;

  const _ParitySelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

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
      onSelectionChanged: enabled
          ? (s) => onChanged(s.first)
          : (_) async {
              await showProDialog(
                context,
                title: l10n.numberParityProTitle,
                message: l10n.numberParityProMessage,
              );
            },
    );
  }
}
