import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import '../../../core/gating/feature_gate.dart';
import '../../../l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/storage/boxes.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final _rng = Random();
  static const int _freeMinSec = 3;
  static const int _freeMaxSec = 12;
  static const _kMinKey = 'time.minSec';
  static const _kMaxKey = 'time.maxSec';

  bool _hideTime = false;

  int _minSec = 3;
  int _maxSec = 8;

  bool _running = false;
  bool _finished = false;
  bool _revealHiddenAtEnd = false;

  int _elapsedMs = 0;
  int? _targetMs;
  Stopwatch? _sw;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    final box = Boxes.box(Boxes.settings);
    _minSec = (box.get(_kMinKey, defaultValue: 3) as num).toInt();
    _maxSec = (box.get(_kMaxKey, defaultValue: 8) as num).toInt();
    if (_maxSec < _minSec) _maxSec = _minSec;
  }

  Future<void> _persistRange() async {
    final box = Boxes.box(Boxes.settings);
    await box.put(_kMinKey, _minSec);
    await box.put(_kMaxKey, _maxSec);
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _reset() {
    _tick?.cancel();
    _sw?.stop();
    setState(() {
      _running = false;
      _finished = false;
      _revealHiddenAtEnd = false;
      _targetMs = null;
      _elapsedMs = 0;
    });
  }

  Future<void> _stop() async {
    _tick?.cancel();
    _sw?.stop();
    final finalMs = _elapsedMs;
    setState(() {
      _running = false;
      _finished = true;
      _targetMs = finalMs;
      _revealHiddenAtEnd = _hideTime;
    });
    await _saveHistory(finalMs);
    await _vibrate();
  }

  Future<void> _finish(int targetMs) async {
    _tick?.cancel();
    _sw?.stop();
    setState(() {
      _running = false;
      _finished = true;
      _elapsedMs = targetMs;
      _revealHiddenAtEnd = _hideTime;
    });
    await _saveHistory(targetMs);
    await _vibrate();
  }

  Future<void> _saveHistory(int ms) async {
    final sec = ms ~/ 1000;
    final milli = (ms % 1000).toString().padLeft(3, '0');
    final value = context.l10n.timeFormatted(sec, milli);
    await context.read<HistoryStore>().add(
      type: GeneratorType.time,
      value: value,
      maxEntries: context.gateRead.historyMax,
      metadata: {'targetMs': ms},
    );
  }

  Future<void> _vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) Vibration.vibrate(duration: 500);
  }

  void _start(bool isPro) {
    _tick?.cancel();

    final minMs = (isPro ? _minSec : _freeMinSec) * 1000;
    final maxMs = (isPro ? _maxSec : _freeMaxSec) * 1000;
    final picked = minMs + _rng.nextInt((maxMs - minMs + 1).clamp(1, maxMs - minMs + 1));

    _sw = Stopwatch()..start();

    setState(() {
      _running = true;
      _finished = false;
      _revealHiddenAtEnd = false;
      _targetMs = picked;
      _elapsedMs = 0;
    });

    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) async {
      if (!mounted) return;
      final elapsed = _sw!.elapsedMilliseconds;
      if (elapsed >= _targetMs!) {
        _sw!.stop();
        setState(() => _elapsedMs = _targetMs!);
        await _finish(_targetMs!);
        return;
      }
      setState(() => _elapsedMs = elapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final isPro = gate.isPro;
    final accent = GeneratorType.time.accentColor;

    String formatMs(int ms) {
      final seconds = ms ~/ 1000;
      final milli = ms % 1000;
      return l10n.timeFormatted(seconds, milli.toString().padLeft(3, '0'));
    }

    final showTime = !_hideTime || _revealHiddenAtEnd;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.timeTitle),
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
                      generatorType: GeneratorType.time,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.time,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Time display (centered) ──────────────────────────────────────
          Expanded(
            child: Center(
              child: _hideTime && _running && !_revealHiddenAtEnd
                  ? _HiddenPulse(running: _running)
                  : Text(
                      _targetMs == null
                          ? l10n.timeReady
                          : formatMs(_elapsedMs),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: _finished
                            ? Colors.red.shade600
                            : (_running ? accent : accent.withOpacity(0.55)),
                      ),
                    ),
            ),
          ),

          // ── Bottom controls (sticky) ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Range label
                Row(
                  children: [
                    GeneratorSectionTitle(l10n.timeRangeSeconds),
                    if (!isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.proPurple.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.proBadge,
                          style: const TextStyle(
                            color: AppColors.proPurple,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Range row
                Row(
                  children: [
                    Expanded(
                      child: isPro
                          ? _TimeStepper(
                              label: l10n.numberMin,
                              value: _minSec,
                              disabled: _running,
                              onChanged: (v) {
                                final newMin = v;
                                final newMax = _maxSec < newMin ? newMin : _maxSec;
                                setState(() {
                                  _minSec = newMin;
                                  _maxSec = newMax;
                                });
                                _persistRange();
                              },
                            )
                          : GestureDetector(
                              onTap: () => showProDialog(
                                context,
                                title: l10n.timeRangeSeconds,
                                message: l10n.timeRangeSeconds,
                                generatorType: GeneratorType.time,
                              ),
                              child: _TimeLockedField(
                                label: l10n.numberMin,
                                value: '$_freeMinSec s',
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isPro
                          ? _TimeStepper(
                              label: l10n.numberMax,
                              value: _maxSec,
                              disabled: _running,
                              onChanged: (v) {
                                final newMax = v;
                                final newMin = _minSec > newMax ? newMax : _minSec;
                                setState(() {
                                  _minSec = newMin;
                                  _maxSec = newMax;
                                });
                                _persistRange();
                              },
                            )
                          : GestureDetector(
                              onTap: () => showProDialog(
                                context,
                                title: l10n.timeRangeSeconds,
                                message: l10n.timeRangeSeconds,
                                generatorType: GeneratorType.time,
                              ),
                              child: _TimeLockedField(
                                label: l10n.numberMax,
                                value: '$_freeMaxSec s',
                              ),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Hide time switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: accent,
                  title: Text(l10n.timeHideTime),
                  value: _hideTime,
                  onChanged: _running ? null : (v) => setState(() => _hideTime = v),
                ),

                const SizedBox(height: 8),

                // Action button
                if (_running)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _stop,
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.timeStop),
                  )
                else if (_finished)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.timeReset),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: AppStyles.generatorButton(accent),
                          onPressed: () => _start(isPro),
                          icon: const Icon(Icons.casino),
                          label: Text(l10n.timeAgain),
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    style: AppStyles.generatorButton(accent),
                    onPressed: () => _start(isPro),
                    icon: const Icon(Icons.casino),
                    label: Text(l10n.timeStart),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.label,
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final bool disabled;
  final ValueChanged<int> onChanged;

  static const _min = 1;
  static const _max = 3600;

  @override
  Widget build(BuildContext context) {
    final accent = GeneratorType.time.accentColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
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
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                color: accent,
                onPressed: disabled
                    ? null
                    : () => onChanged((value - 1).clamp(_min, _max)),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$value s',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                color: accent,
                onPressed: disabled
                    ? null
                    : () => onChanged((value + 1).clamp(_min, _max)),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeLockedField extends StatelessWidget {
  const _TimeLockedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final accent = GeneratorType.time.accentColor;
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

class _HiddenPulse extends StatelessWidget {
  const _HiddenPulse({required this.running});
  final bool running;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: running ? 1 : 0.65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 56),
          const SizedBox(height: 10),
          Text(
            running ? l10n.timeRunning : l10n.timeHidden,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
