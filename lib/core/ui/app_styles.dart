import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static BorderRadius cardRadius = BorderRadius.circular(22);

  static BoxDecoration gradientCard(Color accent) {
    return BoxDecoration(
      borderRadius: cardRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withValues(alpha: 0.20), accent.withValues(alpha: 0.05)],
      ),
    );
  }

  static BoxDecoration glassCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      borderRadius: cardRadius,
      gradient: LinearGradient(
        colors: [primary.withValues(alpha: 0.10), primary.withValues(alpha: 0.03)],
      ),
    );
  }

  static BoxDecoration proCard() {
    return BoxDecoration(
      borderRadius: cardRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.proPurple.withValues(alpha: 0.20),
          AppColors.proPurple.withValues(alpha: 0.06),
        ],
      ),
    );
  }

  static BoxDecoration generatorResultCard(Color accent) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withValues(alpha: 0.20), accent.withValues(alpha: 0.06)],
      ),
      border: Border.all(color: accent.withValues(alpha: 0.28)),
    );
  }

  static ButtonStyle generatorButton(Color accent) {
    return FilledButton.styleFrom(
      backgroundColor: accent.withValues(alpha: 0.16),
      foregroundColor: accent,
      disabledBackgroundColor: accent.withValues(alpha: 0.08),
      disabledForegroundColor: accent.withValues(alpha: 0.45),
      side: BorderSide(color: accent.withValues(alpha: 0.35)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  static TextStyle resultStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
}
