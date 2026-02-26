import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final gate = context.gate; // watch premium changes automatically
    final history = context.read<HistoryStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Number')),
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
                    _last ?? 'Tap "Generate" to get a number',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

          // Range settings
          _SectionTitle('Range'),

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
                  title: 'Custom range is Pro',
                  message:
                      'Free users can generate numbers from 0 to 100. Go Pro to set your own min/max.',
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
            const Text(
              'Max must be >= Min',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 18),

          // Float toggle
          _SectionTitle('Type'),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Float (decimals)'),
            subtitle: Text(
              gate.canUse(ProFeature.numberFloat)
                  ? 'Generate decimal numbers'
                  : 'Pro feature',
            ),
            value: _useFloat,
            onChanged: (v) async {
              if (!gate.canUse(ProFeature.numberFloat)) {
                await showProDialog(
                  context,
                  title: 'Float mode is Pro',
                  message: 'Go Pro to generate decimal numbers.',
                );
                return;
              }
              setState(() => _useFloat = v);
            },
          ),

          const SizedBox(height: 8),

          // Parity filter
          _SectionTitle('Filter'),
          const SizedBox(height: 8),

          _ParitySelector(
            value: _parity,
            enabled: gate.canUse(ProFeature.numberEvenOdd),
            onChanged: (p) async {
              if (!gate.canUse(ProFeature.numberEvenOdd)) {
                await showProDialog(
                  context,
                  title: 'Even/Odd filter is Pro',
                  message: 'Go Pro to filter for even or odd numbers.',
                );
                return;
              }
              setState(() => _parity = p);
            },
          ),

          const SizedBox(height: 24),

          // Generate button
          FilledButton.icon(
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
            label: const Text('Generate'),
          ),

          const SizedBox(height: 24),

          // Free hint
          if (!gate.isPro)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
              child: const Text(
                'Free limits: range 0–100, integer only.\nGo Pro for custom range, floats, and even/odd filters.',
              ),
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
    // For Free, show locked range.
    if (!isPro) {
      return Row(
        children: const [
          Expanded(
            child: _LockedField(label: 'Min', value: '0'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _LockedField(label: 'Max', value: '100'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _NumberField(
            label: 'Min',
            initial: min,
            onSubmitted: (v) => onChanged(v, max),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NumberField(
            label: 'Max',
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
    return SegmentedButton<NumberParity>(
      segments: const [
        ButtonSegment(value: NumberParity.any, label: Text('Any')),
        ButtonSegment(value: NumberParity.even, label: Text('Even')),
        ButtonSegment(value: NumberParity.odd, label: Text('Odd')),
      ],
      selected: {value},
      onSelectionChanged: enabled
          ? (s) => onChanged(s.first)
          : (_) async {
              await showProDialog(
                context,
                title: 'Even/Odd filter is Pro',
                message: 'Go Pro to filter for even or odd numbers.',
              );
            },
    );
  }
}
