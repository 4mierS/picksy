import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../storage/premium_store.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final _rng = Random();

  // Settings
  bool _hideTime = true;
  bool _vibrateOnFinish = true;

  // Pro Range settings (seconds)
  int _minSec = 3;
  int _maxSec = 8;

  // Runtime
  bool _running = false;
  bool _finished = false;
  bool _revealHiddenAtEnd = false;

  int? _targetSec; // random chosen duration
  int? _remainingSec; // countdown
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _reset() {
    _tick?.cancel();
    setState(() {
      _running = false;
      _finished = false;
      _revealHiddenAtEnd = false;
      _targetSec = null;
      _remainingSec = null;
    });
  }

  int _pickRandom(int minSec, int maxSec) {
    if (maxSec < minSec) return minSec;
    final span = maxSec - minSec + 1;
    return minSec + _rng.nextInt(span);
  }

  Future<void> _finish() async {
    _tick?.cancel();
    setState(() {
      _running = false;
      _finished = true;
      _revealHiddenAtEnd = _hideTime;
    });

    if (_vibrateOnFinish) {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(duration: 500);
      }
    }
  }

  void _start({required bool isPro}) {
    _tick?.cancel();

    // Free: fix 2-10s
    final min = isPro ? _minSec : 2;
    final max = isPro ? _maxSec : 10;

    final picked = _pickRandom(min, max);

    setState(() {
      _running = true;
      _finished = false;
      _revealHiddenAtEnd = false;
      _targetSec = picked;
      _remainingSec = picked;
    });

    _tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;

      final next = (_remainingSec ?? 0) - 1;

      if (next <= 0) {
        setState(() {
          _remainingSec = 0;
        });
        await _finish();
        return;
      }

      setState(() {
        _remainingSec = next;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumStore>();
    final isPro = premium.isPro;

    final bg = _finished
        ? Colors.red.shade700
        : Theme.of(context).scaffoldBackgroundColor;

    final showTimeNow = !_hideTime || _revealHiddenAtEnd;
    final timeText = _remainingSec == null ? '--' : '${_remainingSec}s';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Random Time')),
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
                          timeText,
                          style: const TextStyle(
                            fontSize: 64,
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
              hideTime: _hideTime,
              vibrateOnFinish: _vibrateOnFinish,
              minSec: _minSec,
              maxSec: _maxSec,
              onToggleHide: (v) => setState(() => _hideTime = v),
              onToggleVibrate: (v) => setState(() => _vibrateOnFinish = v),
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
                        : (_targetSec == null && !_finished ? null : _reset),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _running ? null : () => _start(isPro: isPro),
                    child: Text(_finished ? 'Again' : 'Start'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              isPro
                  ? 'Pro: choose a custom range.'
                  : 'Free: fixed range 2–10 seconds. Upgrade for custom ranges.',
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

  final bool hideTime;
  final bool vibrateOnFinish;

  final int minSec;
  final int maxSec;

  final ValueChanged<bool> onToggleHide;
  final ValueChanged<bool> onToggleVibrate;
  final void Function(int min, int max) onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final disabled = running;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SwitchListTile(
              value: hideTime,
              onChanged: disabled ? null : onToggleHide,
              title: const Text('Hide time'),
              subtitle: const Text(
                'Reveal the time only when it ends (Hot Potato).',
              ),
            ),
            SwitchListTile(
              value: vibrateOnFinish,
              onChanged: disabled ? null : onToggleVibrate,
              title: const Text('Vibrate on finish'),
            ),
            const Divider(),

            // Range
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Range (seconds)',
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
                    child: const Text('PRO'),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (!isPro)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Free: fixed 2–10s'),
              ),

            if (isPro) ...[
              Row(
                children: [
                  Expanded(
                    child: _NumberStepper(
                      label: 'Min',
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
                      label: 'Max',
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
                  'Current: $minSec – $maxSec s',
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: running ? 1 : 0.65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 56),
          const SizedBox(height: 10),
          Text(
            running ? 'Running…' : 'Hidden',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
