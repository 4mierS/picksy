import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/l10n/l10n.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';
import 'package:picksy/features/generators/shared/generator_widgets.dart' show showProDialog;

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late final AnimationController _flipController;

  bool _flipping = false;
  double _totalFlipAngle = 0.0;
  String _pendingResult = '';
  bool _pendingIsHeads = true;
  bool _showA = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _flipController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _flipping = false;
          _showA = _pendingIsHeads;
        });
        if (!mounted) return;
        await context.read<HistoryStore>().add(
          type: GeneratorType.coin,
          value: _pendingResult,
          maxEntries: context.gateRead.historyMax,
          metadata: {'side': _pendingIsHeads ? 'heads' : 'tails'},
        );
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _flip(String labelA, String labelB) async {
    if (_flipping) return;
    _pendingIsHeads = _rng.nextBool();
    _pendingResult = _pendingIsHeads ? labelA : labelB;
    _totalFlipAngle = (24 + (_pendingIsHeads ? 0 : 1)) * pi;
    setState(() => _flipping = true);
    _flipController.reset();
    await _flipController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final currentA = l10n.coinDefaultHeads;
    final currentB = l10n.coinDefaultTails;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coinTitle),
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
                      generatorType: GeneratorType.coin,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.coin,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _flipController,
                    builder: (context, _) {
                      final t = _flipController.value;
                      final cosVal = cos(t * _totalFlipAngle);
                      final showA = cosVal >= 0;

                      return Transform.translate(
                        offset: Offset(0, -220.0 * sin(pi * t)),
                        child: Transform.scale(
                          scale: 1.0 - 0.6 * sin(pi * t),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(1.0, cosVal.abs()),
                            child: _CoinFace(
                              label: _flipping
                                  ? (showA ? currentA : currentB)
                                  : (_showA ? currentA : currentB),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              FilledButton.icon(
                style: AppStyles.generatorButton(GeneratorType.coin.accentColor),
                icon: const Icon(Icons.casino),
                label: Text(l10n.coinFlip),
                onPressed: _flipping ? null : () => _flip(currentA, currentB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  final String label;
  const _CoinFace({required this.label});

  static const _gold = Color(0xFFFFD54F);
  static const _goldDark = Color(0xFFF57F17);
  static const _goldLight = Color(0xFFFFF9C4);
  static const _rimDark = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.6),
          radius: 0.8,
          colors: [_goldLight, _gold, _goldDark],
          stops: [0.0, 0.35, 1.0],
        ),
        border: Border.all(color: _rimDark, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 28,
            left: 40,
            child: Container(
              width: 50,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _goldLight.withValues(alpha: 0.55),
              ),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: _rimDark,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
