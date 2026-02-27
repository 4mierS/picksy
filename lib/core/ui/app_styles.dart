import 'package:flutter/material.dart';

class AppStyles {
  static BorderRadius cardRadius = BorderRadius.circular(22);

  static BoxDecoration gradientCard(Color accent) {
    return BoxDecoration(
      borderRadius: cardRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withOpacity(0.20), accent.withOpacity(0.05)],
      ),
    );
  }

  static BoxDecoration glassCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      borderRadius: cardRadius,
      gradient: LinearGradient(
        colors: [primary.withOpacity(0.10), primary.withOpacity(0.03)],
      ),
    );
  }

  static TextStyle resultStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
}
