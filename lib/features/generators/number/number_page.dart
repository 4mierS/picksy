import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/storage/boxes.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

enum NumberParity { any }

class NumberPage extends StatefulWidget {
  const NumberPage({super.key});

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  final _rng = Random();
  static const _kMinKey = 'number.min';
  static const _kMaxKey = 'number.max';

  // Free defaults:
  double _min = 0;
  double _max = 100;

  final NumberParity _parity = NumberParity.any;

  late String _last;

  bool get _isValidRange => _max >= _min;

  @override
  void initState() {
    super.initState();
    final box = Boxes.box(Boxes.settings);
    _min = (box.get(_kMinKey, defaultValue: 0) as num).toDouble();
    _max = (box.get(_kMaxKey, defaultValue: 100) as num).toDouble();
    _last = _generateNumber(min: _min, max: _max, parity: NumberParity.any);
  }

  Future<void> _persistRange() async {
    final box = Boxes.box(Boxes.settings);
    await box.put(_kMinKey, _min);
    await box.put(_kMaxKey, _max);
  }

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
      body: Column(
        children: [
          // Result display – centered, large, accent-colored
          Expanded(
            child: Center(
              child: Text(
                _last,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: GeneratorType.number.accentColor,
                ),
              ),
            ),
          ),

          // Range + button anchored at the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GeneratorSectionTitle(l10n.numberSectionRange),
                const SizedBox(height: 8),
                _RangeRow(
                  min: _min,
                  max: _max,
                  isPro: gate.isPro,
                  onChanged: (newMin, newMax) async {
                    if (!gate.canUse(ProFeature.numberCustomRange)) {
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
                    await _persistRange();
                  },
                ),
                if (!_isValidRange) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.numberInvalidRange,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 16),
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

class _RangeRow extends StatelessWidget {
  final double min;
  final double max;
  final bool isPro;
  final void Function(double newMin, double newMax) onChanged;

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
            child: GestureDetector(
              onTap: () async => onChanged(0, 100),
              child: _LockedField(label: l10n.numberMin, value: '0'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async => onChanged(0, 100),
              child: _LockedField(label: l10n.numberMax, value: '100'),
            ),
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
            onChanged: (v) => onChanged(v, max),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NumberField(
            label: l10n.numberMax,
            initial: max,
            onChanged: (v) => onChanged(min, v),
          ),
        ),
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final accent = GeneratorType.number.accentColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.4)),
        color: accent.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double initial;
  final ValueChanged<double> onChanged;

  const _NumberField({
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toStringAsFixed(0));
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus) {
          _commit();
        }
      });
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
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (v == null) return;
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _commit(),
      onEditingComplete: _commit,
      onTapOutside: (_) {
        _commit();
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
