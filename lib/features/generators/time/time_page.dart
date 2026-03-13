import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../../core/gating/feature_gate.dart';
import '../../../l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/storage/premium_store.dart';
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

  // Settings
  bool _hideTime = false;
  bool _vibrateOnFinish = true;

  // Pro Range settings (seconds)
  int _minSec = 3;
  int _maxSec = 8;

  // Runtime
  bool _running = false;
  bool _finished = false;
  bool _revealHiddenAtEnd = false;

  int _elapsedMs = 0;
  int? _targetMs;
  Stopwatch? _sw;
  Timer? _tick;

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

  int _pickRandomMs(int minMs, int maxMs) {
    if (maxMs < minMs) return minMs;
    final span = maxMs - minMs + 1;
    return minMs + _rng.nextInt(span);
  }

  Future<void> _finish({
    required bool hideTime,
    required bool vibrateOnFinish,
  }) async {
    _tick?.cancel();
    _sw?.stop();

    setState(() {
      _running = false;
      _finished = true;
      _revealHiddenAtEnd = hideTime;
    });

    if (_targetMs != null) {
      final sec = _targetMs! ~/ 1000;
      final milli = (_targetMs! % 1000).toString().padLeft(3, '0');
      final value = context.l10n.timeFormatted(sec, milli);
      await context.read<HistoryStore>().add(
        type: GeneratorType.time,
        value: value,
        maxEntries: context.gateRead.historyMax,
        metadata: {'targetMs': _targetMs},
      );
    }

    if (vibrateOnFinish) {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) Vibration.vibrate(duration: 500);
    }
  }

  void _start({
    required bool isPro,
    required int minSec,
    required int maxSec,
    required bool hideTime,
    required bool vibrateOnFinish,
  }) {
    _tick?.cancel();

    final min = isPro ? minSec * 1000 : _freeMinSec * 1000;
    final max = isPro ? maxSec * 1000 : _freeMaxSec * 1000;

    final picked = _pickRandomMs(min, max);

    _sw = Stopwatch()..start();

    setState(() {
      _running = true;
      _finished = false;
      _revealHiddenAtEnd = false;
      _targetMs = picked;
      _elapsedMs = 0;
    });

    _tick = Timer.periodic(const Duration(milliseconds: 16), (t) async {
      if (!mounted) return;

      final elapsed = _sw!.elapsedMilliseconds;

      if (_targetMs != null && elapsed >= _targetMs!) {
        _sw!.stop();
        setState(() => _elapsedMs = _targetMs!);
        await _finish(hideTime: hideTime, vibrateOnFinish: vibrateOnFinish);
        return;
      }

      setState(() => _elapsedMs = elapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = context.watch<PremiumStore>();
    final isPro = premium.isPro;
    final accent = GeneratorType.time.accentColor;

    final showTimeNow = !_hideTime || _revealHiddenAtEnd;

    String formatMs(int ms) {
      final seconds = ms ~/ 1000;
      final milli = ms % 1000;
      return l10n.timeFormatted(seconds, milli.toString().padLeft(3, '0'));
    }

    void openProDialog() => showProDialog(
      context,
      title: l10n.timeRangeSeconds,
      message: l10n.timeProCustomRangeHint,
      generatorType: GeneratorType.time,
    );

    // Build the time display widget used inside ResultDisplayArea
    Widget timeDisplay;
    if (!showTimeNow) {
      timeDisplay = _HiddenPulse(running: _running);
    } else {
      final displayText = _targetMs == null ? l10n.timeReady : formatMs(_elapsedMs);
      timeDisplay = Text(
        displayText,
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800),
      );
    }

    // Tap behaviour: start if not running/finished, reset if finished
    VoidCallback? onTap;
    if (_running) {
      onTap = null;
    } else if (_finished) {
      onTap = _reset;
    } else {
      onTap = () => _start(
        isPro: isPro,
        minSec: _minSec,
        maxSec: _maxSec,
        hideTime: _hideTime,
        vibrateOnFinish: _vibrateOnFinish,
      );
    }

    return Scaffold(
      backgroundColor: _finished
          ? Colors.red.shade700
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.timeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l10n.analyticsTitle,
            onPressed: () {
              if (isPro) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Result area (tap to start / tap again to reset) ───────────────
          ResultDisplayArea(
            accentColor: accent,
            hint: l10n.timeReady,
            minHeight: 160,
            onTap: onTap,
            child: Center(child: timeDisplay),
          ),

          const SizedBox(height: 12),

          // Reset button (always visible once started)
          if (_targetMs != null || _finished)
            OutlinedButton(
              onPressed: _running ? null : _reset,
              child: Text(l10n.timeReset),
            ),

          const SizedBox(height: 24),

          // ── Free controls ─────────────────────────────────────────────────
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.timeHideTime),
            subtitle: Text(l10n.timeHideTimeSubtitle),
            value: _hideTime,
            onChanged: _running ? null : (v) => setState(() => _hideTime = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.timeVibrateOnFinish),
            value: _vibrateOnFinish,
            onChanged:
                _running ? null : (v) => setState(() => _vibrateOnFinish = v),
          ),

          const SizedBox(height: 24),

          // ── Pro features ─────────────────────────────────────────────────
          PremiumSection(
            isPro: isPro,
            onProRequired: openProDialog,
            title: l10n.timeRangeSeconds,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _NumberStepper(
                      label: l10n.numberMin,
                      value: _minSec,
                      min: 1,
                      max: 3600,
                      onChanged: _running
                          ? null
                          : (v) {
                              final newMin = v;
                              final newMax =
                                  _maxSec < newMin ? newMin : _maxSec;
                              setState(() {
                                _minSec = newMin;
                                _maxSec = newMax;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberStepper(
                      label: l10n.numberMax,
                      value: _maxSec,
                      min: 1,
                      max: 3600,
                      onChanged: _running
                          ? null
                          : (v) {
                              final newMax = v;
                              final newMin =
                                  _minSec > newMax ? newMax : _minSec;
                              setState(() {
                                _minSec = newMin;
                                _maxSec = newMax;
                              });
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: onChanged == null
                    ? null
                    : () => onChanged!((value - 1).clamp(min, max)),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onChanged == null
                    ? null
                    : () => onChanged!((value + 1).clamp(min, max)),
                icon: const Icon(Icons.add),
              ),
            ],
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
