import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../ui/app_colors.dart';
import '../../models/generator_type.dart';

import '../../storage/premium_store.dart';
import '../../features/pro/pro_page.dart';

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
  memoryFlashEndless,
  memoryFlashSpeed,
  mathChallengeProDifficulty,
  mathChallengeProDuration,
  cardJokers,
  cardMultiDraw,
  colorReflexDuration,
  tapChallengeDuration,
  ticTacToeLocalMultiplayer,
  ticTacToeDifficulty,
  ticTacToeCustomNames,
  ticTacToeStats,
  connectFourLocalMultiplayer,
  connectFourDifficulty,
  connectFourCustomNames,
  connectFourStats,
}

class FeatureGate {
  final bool isPro;
  const FeatureGate({required this.isPro});

  /// Limits
  static const freeRoundsMax = 10;
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
      case ProFeature.memoryFlashEndless:
      case ProFeature.memoryFlashSpeed:
      case ProFeature.mathChallengeProDifficulty:
      case ProFeature.mathChallengeProDuration:
      case ProFeature.cardJokers:
      case ProFeature.cardMultiDraw:
      case ProFeature.colorReflexDuration:
      case ProFeature.tapChallengeDuration:
      case ProFeature.ticTacToeLocalMultiplayer:
      case ProFeature.ticTacToeDifficulty:
      case ProFeature.ticTacToeCustomNames:
      case ProFeature.ticTacToeStats:
      case ProFeature.connectFourLocalMultiplayer:
      case ProFeature.connectFourDifficulty:
      case ProFeature.connectFourCustomNames:
      case ProFeature.connectFourStats:
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
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFFAB47BC)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    generatorType?.homeIcon ?? Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.proPurple,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  if (dedupedDefinitions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.proPurple.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRO includes:',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.proPurple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final d in dedupedDefinitions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 15,
                                      color: AppColors.proPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      d,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.proPurple,
                      side: const BorderSide(color: AppColors.proPurple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.gateNotNow),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF7C3AED), Color(0xFFAB47BC)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProPage()),
                        );
                      },
                      child: Text(
                        l10n.gateGoPro,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
