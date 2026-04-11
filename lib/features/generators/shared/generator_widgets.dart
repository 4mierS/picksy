import 'package:flutter/material.dart';

import 'package:picksy/core/ui/app_colors.dart';
import 'package:picksy/core/ui/app_styles.dart';

// ---------------------------------------------------------------------------
// ResultDisplayArea
// ---------------------------------------------------------------------------

/// Large interactive result area used by simple generators.
///
/// - Displays the generated value (or [hint] when no result yet).
/// - Takes up the main visual space.
/// - Is **clickable**: tapping it calls [onTap] to generate a new result,
///   replacing the traditional "Generate" button.
/// - An optional [child] can override the default text display for generators
///   that have custom visuals (e.g. Color preview, Time counter).
class ResultDisplayArea extends StatelessWidget {
  /// The current result to display. Shows [hint] when null.
  final String? result;

  /// Placeholder text shown before the first generation.
  final String hint;

  /// Accent color for the card border and gradient.
  final Color accentColor;

  /// Called when the user taps the area. Use to trigger generation.
  final VoidCallback? onTap;

  /// Minimum height of the result card. Defaults to 160.
  final double minHeight;

  /// Font size for the result text. Defaults to 26.
  final double fontSize;

  /// Text alignment for the result text. Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// Optional custom content that replaces the default text display.
  /// When provided, [result], [hint], [fontSize], and [textAlign] are ignored.
  final Widget? child;

  /// Optional trailing widget (e.g. a copy button).
  final Widget? trailing;

  const ResultDisplayArea({
    super.key,
    required this.accentColor,
    required this.hint,
    this.result,
    this.onTap,
    this.minHeight = 160,
    this.fontSize = 26,
    this.textAlign = TextAlign.start,
    this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.generatorResultCard(accentColor),
      child: _buildContent(context),
    );

    if (onTap == null) return container;

    return Semantics(
      button: true,
      label: result ?? hint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: container,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (child != null) {
      if (trailing != null) {
        return Stack(
          children: [
            child!,
            Positioned(top: 0, right: 0, child: trailing!),
          ],
        );
      }
      return child!;
    }

    if (trailing != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              result ?? hint,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
              ),
              textAlign: textAlign,
            ),
          ),
          trailing!,
        ],
      );
    }

    return Text(
      result ?? hint,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
      textAlign: textAlign,
    );
  }
}

// ---------------------------------------------------------------------------
// GeneratorSectionTitle
// ---------------------------------------------------------------------------

/// Standard section header used across generator pages.
class GeneratorSectionTitle extends StatelessWidget {
  final String text;
  const GeneratorSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

// ---------------------------------------------------------------------------
// PremiumFeatureWrapper
// ---------------------------------------------------------------------------

/// Wraps a **single** premium control.
///
/// - When [isPro] is `true`: renders [child] transparently — it works normally.
/// - When [isPro] is `false`: adds a subtle purple tint background and overlays
///   an invisible tap handler that calls [onProRequired], so the child always
///   **looks enabled** (never greyed-out/disabled) but opens the paywall modal
///   when tapped.
class PremiumFeatureWrapper extends StatelessWidget {
  final bool isPro;
  final VoidCallback onProRequired;
  final Widget child;
  final BorderRadius borderRadius;

  const PremiumFeatureWrapper({
    super.key,
    required this.isPro,
    required this.onProRequired,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    if (isPro) return child;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: AppColors.proPurple.withValues(alpha: 0.09),
          ),
          child: child,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onProRequired,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PremiumSection
// ---------------------------------------------------------------------------

/// Groups **all** premium features for a generator into a single visual block.
///
/// - When [isPro] is `true`: renders children normally — they work as usual.
/// - When [isPro] is `false`: wraps the entire section in a purple-tinted
///   rounded container with an invisible tap overlay that calls [onProRequired].
///   All children look normal (not disabled) but the whole section opens the
///   paywall modal when tapped.
///
/// Use this to satisfy the "Feature Grouping Rule" from the design spec:
/// free features first, premium features as a unified block below.
class PremiumSection extends StatelessWidget {
  final List<Widget> children;
  final bool isPro;
  final VoidCallback onProRequired;

  /// Optional header shown above the children. When [isPro] is false a
  /// "PRO" pill badge is appended to the title.
  final String? title;

  const PremiumSection({
    super.key,
    required this.children,
    required this.isPro,
    required this.onProRequired,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            GeneratorSectionTitle(title!),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.proPurple.withValues(alpha: 0.08),
            border: Border.all(color: AppColors.proPurple.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    GeneratorSectionTitle(title!),
                    const SizedBox(width: 8),
                    _ProBadge(),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              ...children,
            ],
          ),
        ),
        // Invisible tap overlay — forwards any tap to the paywall.
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onProRequired,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GeneratorFilters
// ---------------------------------------------------------------------------

/// Thin structural wrapper for the filter section placed below [ResultDisplayArea].
///
/// Renders [children] as a [Column] with consistent spacing and an optional
/// section title. Each child can be a free control or a [PremiumSection].
class GeneratorFilters extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const GeneratorFilters({super.key, required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          GeneratorSectionTitle(title!),
          const SizedBox(height: 8),
        ],
        ...children,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.proPurple.withValues(alpha: 0.15),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.proPurple,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
