import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';

import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/features/analytics/screens/generator_analytics_page.dart';

enum _Phase { idle, waiting, ready, result, tooSoon }

class ReactionTestPage extends StatefulWidget {
  const ReactionTestPage({super.key});

  @override
  State<ReactionTestPage> createState() => _ReactionTestPageState();
}

class _ReactionTestPageState extends State<ReactionTestPage> {
  final _rng = Random();

  _Phase _phase = _Phase.idle;

  Timer? _waitTimer;
  Stopwatch? _sw;

  int? _reactionMs;
  int? _plannedDelayMs;

  bool _vibrateOnResult = true;

  static const int _historyMaxEntries = 100;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _waitTimer?.cancel();
    _sw?.stop();
    setState(() {
      _phase = _Phase.idle;
      _reactionMs = null;
      _plannedDelayMs = null;
    });
  }

  int _pickDelayMs() {
    // random delay 1500–4500ms (fühlt sich gut an)
    return 1500 + _rng.nextInt(3001);
  }

  void _start() {
    _waitTimer?.cancel();
    _sw?.stop();

    final delay = _pickDelayMs();
    setState(() {
      _phase = _Phase.waiting;
      _reactionMs = null;
      _plannedDelayMs = delay;
    });

    _waitTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _sw = Stopwatch()..start();
      setState(() => _phase = _Phase.ready);
    });
  }

  Future<void> _onTap() async {
    final history = context.read<HistoryStore>();

    if (_phase == _Phase.waiting) {
      _waitTimer?.cancel();

      history.add(
        type: GeneratorType.reactionTest,
        value: "Too soon",
        maxEntries: _historyMaxEntries,
      );
      setState(() => _phase = _Phase.tooSoon);

      if (_vibrateOnResult) {
        final hasV = await Vibration.hasVibrator() ?? false;
        if (hasV) Vibration.vibrate(duration: 200);
      }
      return;
    }
    if (_phase == _Phase.ready) {
      _sw?.stop();
      final ms = _sw?.elapsedMilliseconds ?? 0;

      setState(() {
        _reactionMs = ms;
        _phase = _Phase.result;
      });

      history.add(
        type: GeneratorType.reactionTest,
        value: "$ms ms",
        maxEntries: _historyMaxEntries,
        metadata: {'ms': ms},
      );

      if (_vibrateOnResult) {
        final hasV = await Vibration.hasVibrator() ?? false;
        if (hasV) Vibration.vibrate(duration: 300);
      }
      return;
    }

    // In anderen Phasen: noop oder Restart
    if (_phase == _Phase.result || _phase == _Phase.tooSoon) {
      _start();
    }
  }

  Color _bgColor(BuildContext context) {
    switch (_phase) {
      case _Phase.ready:
        return Colors.green.shade700;
      case _Phase.tooSoon:
        return Colors.red.shade700;
      default:
        return Theme.of(context).scaffoldBackgroundColor;
    }
  }

  String _headline() {
    switch (_phase) {
      case _Phase.idle:
        return "Reaction Test";
      case _Phase.waiting:
        return "Wait…";
      case _Phase.ready:
        return "TAP!";
      case _Phase.result:
        return "Your time";
      case _Phase.tooSoon:
        return "Too soon!";
    }
  }

  String _subtext() {
    switch (_phase) {
      case _Phase.idle:
        return "Tap Start, then wait for green.";
      case _Phase.waiting:
        return "Don’t tap yet.";
      case _Phase.ready:
        return "Tap as fast as you can.";
      case _Phase.result:
        return "${_reactionMs ?? 0} ms";
      case _Phase.tooSoon:
        return "You tapped before green. Try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(context);
    final l10n = context.l10n;
    final gate = context.gateRead;

    final showStart = _phase == _Phase.idle;
    final showAgain = _phase == _Phase.result || _phase == _Phase.tooSoon;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Reaction Test"),
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
                      generatorType: GeneratorType.reactionTest,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.reactionTest,
                );
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                decoration: AppStyles.generatorResultCard(
                  GeneratorType.reactionTest.accentColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _headline(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _subtext(),
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Toggle
              Card(
                child: SwitchListTile(
                  title: const Text("Vibrate on result"),
                  value: _vibrateOnResult,
                  onChanged: (v) => setState(() => _vibrateOnResult = v),
                ),
              ),

              const Spacer(),

              if (showStart)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.generatorButton(
                      GeneratorType.reactionTest.accentColor,
                    ),
                    onPressed: _start,
                    child: const Text("Start"),
                  ),
                ),

              if (showAgain)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyles.generatorButton(
                      GeneratorType.reactionTest.accentColor,
                    ),
                    onPressed: _start,
                    child: const Text("Try again"),
                  ),
                ),

              if (!showStart && !showAgain)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text("Reset"),
                  ),
                ),

              const SizedBox(height: 10),
              Text(
                "Tip: You can tap anywhere on the screen.",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
