import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/gating/feature_gate.dart';
import '../../../models/generator_type.dart';
import '../../../storage/history_store.dart';

class BottleSpinPage extends StatefulWidget {
  const BottleSpinPage({super.key});

  @override
  State<BottleSpinPage> createState() => _BottleSpinPageState();
}

class _BottleSpinPageState extends State<BottleSpinPage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  late final AnimationController _controller;

  double _currentAngle = 0.0; // radians
  double _targetAngle = 0.0; // radians
  bool _spinning = false;

  // Pro-only: stronger spin => more turns
  double _spinStrength = 0.6; // 0..1

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1400),
        )..addListener(() {
          // interpolate angle
          final t = Curves.easeOutCubic.transform(_controller.value);
          final angle = _lerp(_currentAngle, _targetAngle, t);
          setState(() => _currentAngle = angle);
        });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() => _spinning = false);

        // Save in history (degrees)
        final deg = ((_currentAngle * 180 / pi) % 360);
        final value = 'Angle: ${deg.toStringAsFixed(0)}°';

        final history = context.read<HistoryStore>();
        await history.add(
          type: GeneratorType.bottleSpin,
          value: value,
          maxEntries: context.gateRead.historyMax,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gate = context.gate;

    return Scaffold(
      appBar: AppBar(title: const Text('Bottle Spin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Place your phone on the table. Tap Spin. The bottle points to someone in the circle.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Bottle area
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: _currentAngle,
                  child: _BottleShape(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: _spinning
                ? null
                : () async {
                    await _spin(gate);
                  },
            icon: const Icon(Icons.casino),
            label: Text(_spinning ? 'Spinning...' : 'Spin'),
          ),

          const SizedBox(height: 16),

          // Pro-only controls
          _SectionTitle('Controls'),
          const SizedBox(height: 8),

          ListTile(
            title: const Text('Spin strength'),
            subtitle: Text(
              gate.canUse(ProFeature.bottleSpinStrength)
                  ? 'More strength = more rotations'
                  : 'Pro feature',
            ),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: _spinStrength,
                onChanged: (v) async {
                  if (!gate.canUse(ProFeature.bottleSpinStrength)) {
                    await showProDialog(
                      context,
                      title: 'Spin strength is Pro',
                      message: 'Go Pro to adjust how strong the bottle spins.',
                    );
                    return;
                  }
                  setState(() => _spinStrength = v);
                },
              ),
            ),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Haptic feedback'),
            subtitle: Text(
              gate.canUse(ProFeature.bottleSpinHaptics)
                  ? 'Vibrate when the bottle stops'
                  : 'Pro feature',
            ),
            value: gate.canUse(ProFeature.bottleSpinHaptics) ? true : false,
            onChanged: (v) async {
              if (!gate.canUse(ProFeature.bottleSpinHaptics)) {
                await showProDialog(
                  context,
                  title: 'Haptics are Pro',
                  message: 'Go Pro to enable vibration feedback.',
                );
                return;
              }
              // MVP: we just trigger vibration on stop; no stored setting yet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Haptics enabled for this session'),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          if (!gate.isPro)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.4),
                ),
              ),
              child: const Text(
                'Free: Spin bottle.\nPro: Adjust spin strength + haptic feedback.',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _spin(FeatureGate gate) async {
    if (_spinning) return;

    setState(() => _spinning = true);

    // random target in degrees
    final randomDeg = _rng.nextInt(360).toDouble();

    // number of full rotations:
    // Free: fixed range
    // Pro: based on strength slider
    final baseTurns = gate.canUse(ProFeature.bottleSpinStrength)
        ? (2 + (_spinStrength * 8))
              .round() // 2..10 turns
        : 5; // fixed

    final extraDeg = baseTurns * 360.0;
    final totalDeg = extraDeg + randomDeg;

    _currentAngle = _currentAngle % (2 * pi);
    _targetAngle = _currentAngle + (totalDeg * pi / 180.0);

    // Pro haptics on start is optional; keep minimal
    if (gate.canUse(ProFeature.bottleSpinHaptics)) {
      HapticFeedback.selectionClick();
    }

    _controller.reset();
    await _controller.forward();

    // Haptics on stop (only if Pro)
    if (gate.canUse(ProFeature.bottleSpinHaptics)) {
      HapticFeedback.mediumImpact();
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class _BottleShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Very simple “bottle”: a rounded rectangle body + triangle tip
    return SizedBox(
      width: 220,
      height: 60,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Body
          Positioned.fill(
            left: 30,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.35),
                ),
              ),
            ),
          ),
          // Neck / Tip
          Positioned(
            left: 0,
            child: CustomPaint(
              size: const Size(40, 60),
              painter: _TipPainter(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Center mark
          Positioned(
            left: 120,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipPainter extends CustomPainter {
  final Color color;
  _TipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.85);

    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TipPainter oldDelegate) =>
      oldDelegate.color != color;
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
