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

enum ColorMode { normal, pastel, neon, dark }

class ColorPage extends StatefulWidget {
  const ColorPage({super.key});

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  final _rng = Random();

  Color _current = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;
    final history = context.read<HistoryStore>();
    final currentHex = _toHex(_current);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.colorTitle),
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
                      generatorType: GeneratorType.color,
                    ),
                  ),
                );
              } else {
                showProDialog(
                  context,
                  title: l10n.analyticsProOnly,
                  message: l10n.analyticsProMessage,
                  generatorType: GeneratorType.color,
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
                  child: _ColorPreview(
                    color: _current,
                    showContrast: gate.canUse(ProFeature.colorContrast),
                  ),
                ),
              ),
              if (!gate.isPro)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyles.proCard(),
                  child: Text(
                    l10n.colorFreeProHint,
                    style: AppStyles.resultStyle,
                  ),
                ),
              if (!gate.isPro) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: currentHex));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.commonCopy),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: AppStyles.generatorButton(
                    GeneratorType.color.accentColor,
                  ),
                  icon: const Icon(Icons.casino),
                  label: Text(l10n.commonGenerate),
                  onPressed: () async {
                    const mode = ColorMode.normal;
                    final color = _generateColor(mode: mode);
                    setState(() => _current = color);

                    await history.add(
                      type: GeneratorType.color,
                      value: _toHex(color),
                      maxEntries: context.gateRead.historyMax,
                      metadata: {'mode': mode.name},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _generateColor({required ColorMode mode}) {
    int r = _rng.nextInt(256);
    int g = _rng.nextInt(256);
    int b = _rng.nextInt(256);

    switch (mode) {
      case ColorMode.pastel:
        r = (r + 255) ~/ 2;
        g = (g + 255) ~/ 2;
        b = (b + 255) ~/ 2;
        break;
      case ColorMode.neon:
        r = (r + 100).clamp(0, 255);
        g = (g + 100).clamp(0, 255);
        b = (b + 100).clamp(0, 255);
        break;
      case ColorMode.dark:
        r = r ~/ 2;
        g = g ~/ 2;
        b = b ~/ 2;
        break;
      case ColorMode.normal:
        break;
    }

    return Color.fromARGB(255, r, g, b);
  }

  String _toHex(Color c) {
    return "#${c.red.toRadixString(16).padLeft(2, '0')}"
            "${c.green.toRadixString(16).padLeft(2, '0')}"
            "${c.blue.toRadixString(16).padLeft(2, '0')}"
        .toUpperCase();
  }
}

class _ColorPreview extends StatelessWidget {
  final Color color;
  final bool showContrast;

  const _ColorPreview({required this.color, required this.showContrast});

  @override
  Widget build(BuildContext context) {
    final hex =
        "#${color.red.toRadixString(16).padLeft(2, '0')}"
                "${color.green.toRadixString(16).padLeft(2, '0')}"
                "${color.blue.toRadixString(16).padLeft(2, '0')}"
            .toUpperCase();

    final contrast = _isLight(color) ? Colors.black : Colors.white;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            hex,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: showContrast ? contrast : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool _isLight(Color c) {
    final brightness = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return brightness > 0.5;
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  const _ColorBox(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
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

class _ModeSelector extends StatelessWidget {
  final ColorMode mode;
  final bool enabled;
  final List<String> proDefinitions;
  final ValueChanged<ColorMode> onChanged;

  const _ModeSelector({
    required this.mode,
    required this.enabled,
    required this.proDefinitions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<ColorMode>(
      segments: [
        ButtonSegment(
          value: ColorMode.normal,
          label: Text(l10n.colorModeNormal),
        ),
        ButtonSegment(
          value: ColorMode.pastel,
          label: Text(l10n.colorModePastel),
        ),
        ButtonSegment(value: ColorMode.neon, label: Text(l10n.colorModeNeon)),
        ButtonSegment(value: ColorMode.dark, label: Text(l10n.colorModeDark)),
      ],
      selected: {mode},
      onSelectionChanged: enabled
          ? (s) => onChanged(s.first)
          : (_) async {
              await showProDialog(
                context,
                title: l10n.colorModesProTitle,
                message: l10n.colorModesUpgradeMessage,
                generatorType: GeneratorType.color,
                featureDefinitions: proDefinitions,
              );
            },
    );
  }
}
