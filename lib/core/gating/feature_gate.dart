import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
}

class FeatureGate {
  final bool isPro;
  const FeatureGate({required this.isPro});

  /// Limits
  int get favoritesMax => isPro ? 999 : 2;
  int get historyMax => isPro ? 50 : 3;
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
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to Pro tab (index 1 in your AppShell)
            // For MVP: we just show a snack. Later, wire actual navigation.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Open Pro tab to upgrade')),
            );
          },
          child: const Text('Go Pro'),
        ),
      ],
    ),
  );
}
