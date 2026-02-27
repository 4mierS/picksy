import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';

class BottleSpinPage extends StatefulWidget {
  const BottleSpinPage({super.key});

  @override
  State<BottleSpinPage> createState() => _BottleSpinPageState();
}

class _BottleSpinPageState extends State<BottleSpinPage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  late final AnimationController _controller;
  late Animation<double> _animation;

  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  bool _spinning = false;

  double _spinStrength = 0.6;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + _rng.nextInt(3000)),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _controller.addListener(() {
      // interpolate angle using curved progress 0..1
      final t = _animation.value;
      final angle = _lerp(_currentAngle, _targetAngle, t);
      setState(() => _currentAngle = angle);
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() => _spinning = false);

        final deg = ((_currentAngle * 180 / pi) % 360);
        final value = context.l10n.bottleSpinAngleValue(deg.toStringAsFixed(0));

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
    final l10n = context.l10n;
    final gate = context.gate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bottleSpinTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.bottleSpinInstructions, style: TextStyle(fontSize: 14)),
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
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _spinning
                ? null
                : () async {
                    await _spin(gate);
                  },
            icon: const Icon(Icons.casino),
            label: Text(
              _spinning ? l10n.bottleSpinSpinning : l10n.bottleSpinSpin,
            ),
          ),

          const SizedBox(height: 16),

          // Pro-only controls
          _SectionTitle(l10n.bottleSpinSectionControls),
          const SizedBox(height: 8),

          ListTile(
            title: Text(l10n.bottleSpinStrength),
            subtitle: Text(
              gate.canUse(ProFeature.bottleSpinStrength)
                  ? l10n.bottleSpinStrengthSubtitle
                  : l10n.commonProFeature,
            ),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: _spinStrength,
                onChanged: (v) async {
                  if (!gate.canUse(ProFeature.bottleSpinStrength)) {
                    await showProDialog(
                      context,
                      title: l10n.bottleSpinStrengthProTitle,
                      message: l10n.bottleSpinStrengthProMessage,
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
            title: Text(l10n.bottleSpinHaptic),
            subtitle: Text(
              gate.canUse(ProFeature.bottleSpinHaptics)
                  ? l10n.bottleSpinHapticSubtitle
                  : l10n.commonProFeature,
            ),
            value: gate.canUse(ProFeature.bottleSpinHaptics) ? true : false,
            onChanged: (v) async {
              if (!gate.canUse(ProFeature.bottleSpinHaptics)) {
                await showProDialog(
                  context,
                  title: l10n.bottleSpinHapticProTitle,
                  message: l10n.bottleSpinHapticProMessage,
                );
                return;
              }
              // MVP: we just trigger vibration on stop; no stored setting yet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.bottleSpinHapticEnabled)),
              );
            },
          ),

          const SizedBox(height: 16),

          if (!gate.isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyles.glassCard(context),
              child: Text(
                l10n.bottleSpinFreeProHint,
                style: AppStyles.resultStyle,
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
