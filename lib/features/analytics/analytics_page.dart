import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:picksy/core/gating/feature_gate.dart';
import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';
import 'package:picksy/l10n/l10n.dart';
import 'package:picksy/models/generator_type.dart';
import 'package:picksy/storage/history_store.dart';

import 'screens/generator_analytics_page.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = context.gate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analyticsTitle)),
      body: gate.isPro ? const _AnalyticsGrid() : _UpsellView(),
    );
  }
}

class _UpsellView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: AppStyles.proCard(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart, size: 56, color: AppColors.proPurple),
              const SizedBox(height: 16),
              Text(
                l10n.analyticsProOnly,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.proPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.analyticsProMessage,
                style: const TextStyle(fontSize: 15, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.proPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  showProDialog(
                    context,
                    title: context.l10n.analyticsProOnly,
                    message: context.l10n.analyticsProMessage,
                  );
                },
                child: Text(context.l10n.gateGoPro),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsGrid extends StatelessWidget {
  const _AnalyticsGrid();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryStore>();

    final types = GeneratorType.values;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final count = history.forGenerator(type).length;
        return _GeneratorCard(type: type, count: count);
      },
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  final GeneratorType type;
  final int count;

  const _GeneratorCard({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = type.accentColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneratorAnalyticsPage(generatorType: type),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppStyles.generatorResultCard(accent),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(type.homeIcon, color: accent, size: 28),
            const SizedBox(height: 8),
            Text(
              type.localizedTitle(context),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '$count ${l10n.analyticsTotal.toLowerCase()}',
              style: TextStyle(
                fontSize: 12,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
