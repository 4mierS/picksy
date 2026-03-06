import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../core/ui/app_colors.dart';

class CompareFreePro extends StatelessWidget {
  const CompareFreePro({super.key});

  static const _cellPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 10);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final features = [
      (l10n.compareFeatureHistory, l10n.compareFreeHistory, l10n.compareProHistory),
      (l10n.compareFeatureFavorites, l10n.compareFreeFavorites, l10n.compareProFavorites),
      (l10n.compareFeatureCoinLabels, '✗', '✓'),
      (l10n.compareFeatureColorModes, '✗', '✓'),
      (l10n.compareFeatureCustomRange, '✗', '✓'),
      (l10n.compareFeatureLetterFilters, '✗', '✓'),
      (l10n.compareFeatureCustomListExtras, '✗', '✓'),
      (l10n.compareFeatureBottleHaptics, '✗', '✓'),
      (l10n.compareFeatureTimeRange, '✗', '✓'),
      (l10n.compareFeatureAnalytics, '✗', '✓'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.compareTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.proPurple.withOpacity(0.12),
              ),
              children: [
                _cell(l10n.compareFeatureLabel, bold: true),
                _cell(l10n.compareFreeColumn, bold: true, center: true),
                _cell(
                  l10n.compareProColumn,
                  bold: true,
                  center: true,
                  color: AppColors.proPurple,
                ),
              ],
            ),
            // Feature rows
            for (final (feature, free, pro) in features)
              TableRow(
                children: [
                  _cell(feature),
                  _cell(
                    free,
                    center: true,
                    color: free == '✗'
                        ? Colors.red.withOpacity(0.7)
                        : null,
                  ),
                  _cell(
                    pro,
                    center: true,
                    color: pro == '✓' ? Colors.green : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    bool bold = false,
    bool center = false,
    Color? color,
  }) {
    return Padding(
      padding: _cellPadding,
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
