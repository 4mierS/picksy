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

class ColorPage extends StatefulWidget {
  const ColorPage({super.key});

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  final _rng = Random();

  late Color _current;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _current = _generateColor();
  }

  Future<void> _copy(String hex) async {
    await Clipboard.setData(ClipboardData(text: hex));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

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
                  child: GestureDetector(
                    onTap: () => _showColorFormats(context, _current),
                    child: _ColorPreview(
                      color: _current,
                      showContrast: gate.canUse(ProFeature.colorContrast),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: AppStyles.generatorButton(
                        GeneratorType.color.accentColor,
                      ),
                      icon: const Icon(Icons.casino),
                      label: Text(l10n.commonGenerate),
                      onPressed: () async {
                        final color = _generateColor();
                        setState(() => _current = color);

                        await history.add(
                          type: GeneratorType.color,
                          value: _toHex(color),
                          maxEntries: context.gateRead.historyMax,
                          metadata: {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: AppStyles.generatorButton(
                      GeneratorType.color.accentColor,
                    ).copyWith(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.all(16),
                      ),
                    ),
                    onPressed: _copied ? null : () => _copy(currentHex),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _copied ? Icons.check : Icons.copy,
                        key: ValueKey(_copied),
                        color: _copied ? Colors.green : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorFormats(BuildContext context, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ColorFormatsSheet(color: color),
    );
  }

  Color _generateColor() {
    int r = _rng.nextInt(256);
    int g = _rng.nextInt(256);
    int b = _rng.nextInt(256);

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

class _ColorFormatsSheet extends StatelessWidget {
  final Color color;

  const _ColorFormatsSheet({required this.color});

  @override
  Widget build(BuildContext context) {
    final formats = _buildFormats(color);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // color swatch
          Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
          ...formats.map((f) => _FormatTile(label: f.$1, value: f.$2)),
        ],
      ),
    );
  }

  List<(String, String)> _buildFormats(Color c) {
    final r = c.red;
    final g = c.green;
    final b = c.blue;

    final hex = "#${r.toRadixString(16).padLeft(2, '0')}"
            "${g.toRadixString(16).padLeft(2, '0')}"
            "${b.toRadixString(16).padLeft(2, '0')}"
        .toUpperCase();

    // HSL
    final (h, s, l) = _toHsl(r, g, b);
    // HSB
    final (hb, sb, v) = _toHsb(r, g, b);
    // CMYK
    final (cy, m, y, k) = _toCmyk(r, g, b);

    return [
      ('HEX', hex),
      ('RGB', 'rgb($r, $g, $b)'),
      ('HSL', 'hsl(${h.round()}°, ${(s * 100).round()}%, ${(l * 100).round()}%)'),
      ('HSB', 'hsb(${hb.round()}°, ${(sb * 100).round()}%, ${(v * 100).round()}%)'),
      ('CMYK', 'cmyk(${(cy * 100).round()}%, ${(m * 100).round()}%, ${(y * 100).round()}%, ${(k * 100).round()}%)'),
    ];
  }

  (double, double, double) _toHsl(int r, int g, int b) {
    final rf = r / 255, gf = g / 255, bf = b / 255;
    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    final delta = max - min;
    final l = (max + min) / 2;
    if (delta == 0) return (0, 0, l);
    final s = delta / (1 - (2 * l - 1).abs());
    double h;
    if (max == rf) {
      h = ((gf - bf) / delta) % 6;
    } else if (max == gf) {
      h = (bf - rf) / delta + 2;
    } else {
      h = (rf - gf) / delta + 4;
    }
    return (h * 60 < 0 ? h * 60 + 360 : h * 60, s, l);
  }

  (double, double, double) _toHsb(int r, int g, int b) {
    final rf = r / 255, gf = g / 255, bf = b / 255;
    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    final delta = max - min;
    final v = max;
    if (max == 0) return (0, 0, 0);
    final s = delta / max;
    double h;
    if (delta == 0) {
      h = 0;
    } else if (max == rf) {
      h = ((gf - bf) / delta) % 6;
    } else if (max == gf) {
      h = (bf - rf) / delta + 2;
    } else {
      h = (rf - gf) / delta + 4;
    }
    return (h * 60 < 0 ? h * 60 + 360 : h * 60, s, v);
  }

  (double, double, double, double) _toCmyk(int r, int g, int b) {
    final rf = r / 255, gf = g / 255, bf = b / 255;
    final k = 1 - [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    if (k == 1) return (0, 0, 0, 1);
    final c = (1 - rf - k) / (1 - k);
    final m = (1 - gf - k) / (1 - k);
    final y = (1 - bf - k) / (1 - k);
    return (c, m, y, k);
  }
}

class _FormatTile extends StatefulWidget {
  final String label;
  final String value;

  const _FormatTile({required this.label, required this.value});

  @override
  State<_FormatTile> createState() => _FormatTileState();
}

class _FormatTileState extends State<_FormatTile> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        widget.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
      subtitle: Text(
        widget.value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          key: ValueKey(_copied),
          icon: Icon(
            _copied ? Icons.check : Icons.copy,
            size: 18,
            color: _copied ? Colors.green : null,
          ),
          onPressed: _copy,
        ),
      ),
    );
  }
}
