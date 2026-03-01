import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../ui/app_colors.dart';
import '../../models/generator_type.dart';

import '../../storage/premium_store.dart';

/// Define all Pro-gated capabilities in one place.
enum ProFeature {
  favoritesUnlimited,
  historyLimit50,
  numberCustomRange,
  numberEvenOdd,
  numberFloat,
  letterFilters,
  colorPalette,
  colorModes,
  colorContrast,
  customListUndo,
  customListWeighted,
  wordAdvancedPacks,
  bottleSpinStrength,
  bottleSpinHaptics,
  workflowUnlimitedFields,
  presetsUnlimited,
  exportShare,
  coinCustomLabels,
  timeCustomRange,
  analyticsAccess,
  autoRun,
  colorReflexDuration,
}

class FeatureGate {
  final bool isPro;
  const FeatureGate({required this.isPro});

  /// Limits
  int get favoritesMax => isPro ? 999 : 2;
  int get historyMax => isPro ? 1000 : 3;
  int get workflowFieldsMax => isPro ? 999 : 3;
  int get presetsMax => isPro ? 999 : 2;

  /// Base checks (feature flags)
  bool canUse(ProFeature f) {
    if (isPro) return true;

    // Free users: only allow non-pro features.
    switch (f) {
      // These are Pro-only
      case ProFeature.favoritesUnlimited:
      case ProFeature.historyLimit50:
      case ProFeature.numberCustomRange:
      case ProFeature.numberEvenOdd:
      case ProFeature.numberFloat:
      case ProFeature.letterFilters:
      case ProFeature.colorPalette:
      case ProFeature.colorModes:
      case ProFeature.colorContrast:
      case ProFeature.customListUndo:
      case ProFeature.customListWeighted:
      case ProFeature.wordAdvancedPacks:
      case ProFeature.bottleSpinStrength:
      case ProFeature.bottleSpinHaptics:
      case ProFeature.workflowUnlimitedFields:
      case ProFeature.presetsUnlimited:
      case ProFeature.exportShare:
      case ProFeature.coinCustomLabels:
      case ProFeature.timeCustomRange:
      case ProFeature.analyticsAccess:
      case ProFeature.autoRun:
      case ProFeature.colorReflexDuration:
        return false;
    }
  }

  /// Helper for "limit reached" checks.
  bool withinLimit(int current, int max) => current < max;
}

/// Quick access from BuildContext:
extension FeatureGateX on BuildContext {
  FeatureGate get gate => FeatureGate(isPro: watch<PremiumStore>().isPro);
  FeatureGate get gateRead => FeatureGate(isPro: read<PremiumStore>().isPro);
  FeatureGate get gateNoWatch => FeatureGate(isPro: read<PremiumStore>().isPro);
}

/// Standard Pro dialog (simple MVP paywall prompt)
Future<void> showProDialog(
  BuildContext context, {
  required String title,
  required String message,
  GeneratorType? generatorType,
  List<String> featureDefinitions = const [],
}) async {
  final l10n = context.l10n;
  final dedupedDefinitions = featureDefinitions
      .where((e) => e.trim().isNotEmpty)
      .toSet()
      .toList();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Row(
        children: [
          if (generatorType != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: generatorType.accentColor.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                generatorType.homeIcon,
                color: generatorType.accentColor,
                size: 20,
              ),
            ),
          if (generatorType != null) const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.proPurple,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 15, height: 1.3)),
              if (dedupedDefinitions.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'PRO includes:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.proPurple,
                  ),
                ),
                const SizedBox(height: 8),
                for (final d in dedupedDefinitions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.proPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(d)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.proPurple),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.gateNotNow),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.proPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to Pro tab (index 1 in your AppShell)
            // For MVP: we just show a snack. Later, wire actual navigation.
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.gateOpenProTab)));
          },
          child: Text(l10n.gateGoPro),
        ),
      ],
    ),
  );
}
