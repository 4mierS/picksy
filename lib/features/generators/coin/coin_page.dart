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
import 'package:picksy/features/generators/shared/generator_widgets.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  bool _flipping = false;
  double _totalFlipAngle = 0.0;
  String _pendingResult = '';
  bool _pendingIsHeads = true;

  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  // Pro-only
  final _labelA = TextEditingController();
  final _labelB = TextEditingController();

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    _flipController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _flipping = false;
        });

        if (!mounted) return;
        final history = context.read<HistoryStore>();
        await history.add(
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
    _labelA.dispose();
    _labelB.dispose();
    super.dispose();
  }

  Future<void> _flip(String labelA, String labelB) async {
    if (_flipping) return;

    _pendingIsHeads = _rng.nextBool();
    _pendingResult = _pendingIsHeads ? labelA : labelB;

    final halfFlips = 6 + (_pendingIsHeads ? 0 : 1);
    _totalFlipAngle = halfFlips * pi;

    setState(() => _flipping = true);
    _flipController.reset();
    await _flipController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_labelA.text.isEmpty) _labelA.text = l10n.coinDefaultHeads;
    if (_labelB.text.isEmpty) _labelB.text = l10n.coinDefaultTails;
    final gate = context.gate;
    final accent = GeneratorType.coin.accentColor;

    final canCustomLabels = gate.canUse(ProFeature.coinCustomLabels);
    final proDefinitions = [l10n.coinCustomLabelsProMessage];
    final currentA = canCustomLabels ? _labelA.text.trim() : l10n.coinDefaultHeads;
    final currentB = canCustomLabels ? _labelB.text.trim() : l10n.coinDefaultTails;

    void openProDialog() => showProDialog(
      context,
      title: l10n.coinCustomLabelsProTitle,
      message: l10n.coinCustomLabelsProMessage,
      generatorType: GeneratorType.coin,
      featureDefinitions: [l10n.coinCustomLabelsProMessage],
    );

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
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, _) {
                      final angle = _flipAnimation.value * _totalFlipAngle;
                      final cosVal = cos(angle);
                      final scaleX = cosVal.abs();
                      final showA = cosVal >= 0;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(scaleX, 1.0),
                        child: _CoinFace(label: showA ? currentA : currentB),
                      );
                    },
                  ),
                ),
              ),
              GeneratorSectionTitle(l10n.coinSectionLabels),
              const SizedBox(height: 8),

              // Pro-only label inputs
              TextField(
                controller: _labelA,
                enabled: canCustomLabels,
                decoration: InputDecoration(
                  labelText: l10n.coinOptionA,
                  hintText: l10n.coinHintA,
                  suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
                ),
                onTap: () async {
                  if (!canCustomLabels) {
                    await showProDialog(
                      context,
                      title: l10n.coinCustomLabelsProTitle,
                      message: l10n.coinCustomLabelsProMessage,
                      generatorType: GeneratorType.coin,
                      featureDefinitions: proDefinitions,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _labelB,
                enabled: canCustomLabels,
                decoration: InputDecoration(
                  labelText: l10n.coinOptionB,
                  hintText: l10n.coinHintB,
                  suffixIcon: canCustomLabels ? null : const Icon(Icons.lock),
                ),
                onTap: () async {
                  if (!canCustomLabels) {
                    await showProDialog(
                      context,
                      title: l10n.coinCustomLabelsProTitle,
                      message: l10n.coinCustomLabelsProMessage,
                      generatorType: GeneratorType.coin,
                      featureDefinitions: proDefinitions,
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              if (!gate.isPro)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: AppStyles.proCard(),
                  child: Text(
                    l10n.coinFreeProHint,
                    style: AppStyles.resultStyle,
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: AppStyles.generatorButton(
                    GeneratorType.coin.accentColor,
                  ),
                  icon: const Icon(Icons.casino),
                  label: Text(l10n.coinFlip),
                  onPressed: _flipping ? null : () => _flip(currentA, currentB),
                ),
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

  @override
  Widget build(BuildContext context) {
    final color = GeneratorType.coin.accentColor;
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 4),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
