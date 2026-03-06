import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

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
  double _startAngle = 0.0;
  double _targetAngle = 0.0;
  bool _spinning = false;
  String? _lastResult;

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
      // interpolate angle using curved progress 0..1 from fixed _startAngle
      final t = _animation.value;
      setState(() => _currentAngle = _lerp(_startAngle, _targetAngle, t));
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final deg = ((_currentAngle * 180 / pi) % 360);
        final value = context.l10n.bottleSpinAngleValue(deg.toStringAsFixed(0));

        setState(() {
          _spinning = false;
          _lastResult = value;
        });

        final history = context.read<HistoryStore>();
        await history.add(
          type: GeneratorType.bottleSpin,
          value: value,
          maxEntries: context.gateRead.historyMax,
          metadata: {'degrees': deg},
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
      appBar: AppBar(
        title: Text(l10n.bottleSpinTitle),
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
                      generatorType: GeneratorType.bottleSpin,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.bottleSpin,
                );
              }
            },
          ),
        ],
      ),
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

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 110),
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.generatorResultCard(
              GeneratorType.bottleSpin.accentColor,
            ),
            child: Text(
              _lastResult ?? l10n.bottleSpinSpin,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 14),

          FilledButton.icon(
            style: AppStyles.generatorButton(
              GeneratorType.bottleSpin.accentColor,
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
        ],
      ),
    );
  }

  Future<void> _spin(FeatureGate gate) async {
    if (_spinning) return;

    setState(() => _spinning = true);

    // random target in degrees
    final randomDeg = _rng.nextInt(360).toDouble();

    final baseTurns = 3 + _rng.nextInt(8); // 3..10 random turns

    final extraDeg = baseTurns * 360.0;
    final totalDeg = extraDeg + randomDeg;

    _startAngle = _currentAngle % (2 * pi);
    _currentAngle = _startAngle;
    _targetAngle = _startAngle + (totalDeg * pi / 180.0);

    // Randomise duration each spin for variety
    _controller.duration = Duration(milliseconds: 3000 + _rng.nextInt(2000));

    HapticFeedback.selectionClick();

    _controller.reset();
    await _controller.forward();

    HapticFeedback.mediumImpact();
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
