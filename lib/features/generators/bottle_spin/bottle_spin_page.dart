import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart';

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
      final t = _animation.value;
      setState(() => _currentAngle = _lerp(_startAngle, _targetAngle, t));
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final deg = (_currentAngle * 180 / pi) % 360;
        final value = context.l10n.bottleSpinAngleValue(
          deg.toStringAsFixed(0),
        );
        setState(() => _spinning = false);

        await context.read<HistoryStore>().add(
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

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);

    final randomDeg = _rng.nextInt(360).toDouble();
    final extraDeg = (3 + _rng.nextInt(8)) * 360.0;

    _startAngle = _currentAngle % (2 * pi);
    _currentAngle = _startAngle;
    _targetAngle = _startAngle + (extraDeg + randomDeg) * pi / 180.0;

    _controller.duration = Duration(milliseconds: 3000 + _rng.nextInt(2000));

    HapticFeedback.selectionClick();
    _controller.reset();
    await _controller.forward();
    HapticFeedback.mediumImpact();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final accent = GeneratorType.bottleSpin.accentColor;

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
      body: Column(
        children: [
          // Bottle centered in expanded area
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle table circle
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.05),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Rotating bottle
                  Transform.rotate(
                    angle: _currentAngle,
                    child: CustomPaint(
                      size: const Size(280, 78),
                      painter: _BottlePainter(color: accent),
                    ),
                  ),
                  // Pivot dot
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: accent, width: 2.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Spin button at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  style: AppStyles.generatorButton(accent),
                  onPressed: _spinning ? null : _spin,
                  icon: const Icon(Icons.casino),
                  label: Text(
                    _spinning ? l10n.bottleSpinSpinning : l10n.bottleSpinSpin,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final Color color;
  const _BottlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height / 2;

    // Shape proportions
    final neckEndX = w * 0.22;
    final bodyH = size.height * 0.80;
    final neckH = size.height * 0.36;
    const bodyR = 18.0;

    final path = Path()
      // Tip (sharp point, left)
      ..moveTo(0, cy)
      // Upper neck
      ..lineTo(neckEndX - 8, cy - neckH / 2)
      // Curve into body top
      ..quadraticBezierTo(
        neckEndX + 14,
        cy - neckH / 2,
        neckEndX + 24,
        cy - bodyH / 2,
      )
      // Body top
      ..lineTo(w - bodyR, cy - bodyH / 2)
      // Top-right arc
      ..arcToPoint(
        Offset(w, cy - bodyH / 2 + bodyR),
        radius: const Radius.circular(bodyR),
      )
      // Right side
      ..lineTo(w, cy + bodyH / 2 - bodyR)
      // Bottom-right arc
      ..arcToPoint(
        Offset(w - bodyR, cy + bodyH / 2),
        radius: const Radius.circular(bodyR),
      )
      // Body bottom
      ..lineTo(neckEndX + 24, cy + bodyH / 2)
      // Curve into lower neck
      ..quadraticBezierTo(
        neckEndX + 14,
        cy + neckH / 2,
        neckEndX - 8,
        cy + neckH / 2,
      )
      ..close();

    // Main fill
    canvas.drawPath(path, Paint()..color = color);

    // White highlight stripe (glassy look)
    final hx = neckEndX + 34;
    final hw = (w - hx) * 0.32;
    final hy = cy - bodyH / 2 + 5;
    final hh = bodyH * 0.42;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx, hy, hw, hh),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Subtle outline
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BottlePainter old) => old.color != color;
}
