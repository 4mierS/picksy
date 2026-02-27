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

  int _elapsedMs = 0; // for progress display, not critical to be exact
  int? _targetMs; // the picked random time to count down from
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
    final hideTime = _hideTime;
    final vibrateOnFinish = _vibrateOnFinish;
    final minSec = _minSec;
    final maxSec = _maxSec;

    final bg = _finished
        ? Colors.red.shade700
        : Theme.of(context).scaffoldBackgroundColor;

    final showTimeNow = !hideTime || _revealHiddenAtEnd;

    String _formatMs(int ms) {
      final seconds = ms ~/ 1000;
      final milli = ms % 1000;
      return l10n.timeFormatted(seconds, milli.toString().padLeft(3, '0'));
    }

    final timeText = _formatMs(_elapsedMs);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text(l10n.timeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: _finished
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: showTimeNow
                      ? Text(
                          _targetMs == null ? l10n.timeReady : timeText,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : _HiddenPulse(running: _running),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _ControlsCard(
              isPro: isPro,
              running: _running,
              freeMinSec: _freeMinSec,
              freeMaxSec: _freeMaxSec,
              hideTime: hideTime,
              vibrateOnFinish: vibrateOnFinish,
              minSec: minSec,
              maxSec: maxSec,
              onToggleHide: (value) => setState(() => _hideTime = value),
              onToggleVibrate: (value) =>
                  setState(() => _vibrateOnFinish = value),
              onRangeChanged: (min, max) => setState(() {
                _minSec = min;
                _maxSec = max;
              }),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _running
                        ? _reset
                        : (_targetMs == null && !_finished ? null : _reset),
                    child: Text(l10n.timeReset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _running
                        ? null
                        : () => _start(
                            isPro: isPro,
                            minSec: minSec,
                            maxSec: maxSec,
                            hideTime: hideTime,
                            vibrateOnFinish: vibrateOnFinish,
                          ),
                    child: Text(_finished ? l10n.timeAgain : l10n.timeStart),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              isPro
                  ? l10n.timeProCustomRangeHint
                  : l10n.timeFreeCustomRangeHint(_freeMinSec, _freeMaxSec),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.isPro,
    required this.running,
    required this.freeMinSec,
    required this.freeMaxSec,
    required this.hideTime,
    required this.vibrateOnFinish,
    required this.minSec,
    required this.maxSec,
    required this.onToggleHide,
    required this.onToggleVibrate,
    required this.onRangeChanged,
  });

  final bool isPro;
  final bool running;
  final int freeMinSec;
  final int freeMaxSec;

  final bool hideTime;
  final bool vibrateOnFinish;

  final int minSec;
  final int maxSec;

  final ValueChanged<bool> onToggleHide;
  final ValueChanged<bool> onToggleVibrate;
  final void Function(int min, int max) onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final disabled = running;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SwitchListTile(
              value: hideTime,
              onChanged: disabled ? null : onToggleHide,
              title: Text(l10n.timeHideTime),
              subtitle: Text(l10n.timeHideTimeSubtitle),
            ),
            SwitchListTile(
              value: vibrateOnFinish,
              onChanged: disabled ? null : onToggleVibrate,
              title: Text(l10n.timeVibrateOnFinish),
            ),
            const Divider(),

            // Range
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.timeRangeSeconds,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (!isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(l10n.proBadge),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (!isPro)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.timeFreeFixedRange(freeMinSec, freeMaxSec)),
              ),

            if (isPro) ...[
              Row(
                children: [
                  Expanded(
                    child: _NumberStepper(
                      label: l10n.numberMin,
                      value: minSec,
                      min: 1,
                      max: 3600,
                      onChanged: disabled
                          ? null
                          : (v) {
                              final newMin = v;
                              final newMax = maxSec < newMin ? newMin : maxSec;
                              onRangeChanged(newMin, newMax);
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberStepper(
                      label: l10n.numberMax,
                      value: maxSec,
                      min: 1,
                      max: 3600,
                      onChanged: disabled
                          ? null
                          : (v) {
                              final newMax = v;
                              final newMin = minSec > newMax ? newMax : minSec;
                              onRangeChanged(newMin, newMax);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.timeCurrentRange(minSec, maxSec),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
