import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';

import '../../storage/premium_store.dart';
import '../../core/ui/app_styles.dart';
import '../../core/ui/app_colors.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = context.watch<PremiumStore>();
    final lifetime = premium.productById(PremiumStore.lifetimeId);
    final lifetimePrice = lifetime?.price ?? l10n.proLifetimeFallbackPrice;
    final canBuy = premium.isAvailable && !premium.isLoading && !premium.isPro && lifetime != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proGoPro),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    AppColors.proPurple.withValues(alpha: 0.95),
                    AppColors.proPurple.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Text(
                premium.isPro ? l10n.proActiveBadge : l10n.proBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
      body: premium.isPro ? _buildAlreadyPro(l10n) : _buildUpgrade(context, l10n, premium, lifetimePrice, canBuy),
    );
  }

  // ── Already Pro ────────────────────────────────────────────────────────────

  Widget _buildAlreadyPro(dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFFAB47BC)],
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.proActiveBadge,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.proPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.proThanksActive,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upgrade screen ─────────────────────────────────────────────────────────

  Widget _buildUpgrade(
    BuildContext context,
    dynamic l10n,
    PremiumStore premium,
    String price,
    bool canBuy,
  ) {
    return ListView(
      children: [
        // ── Hero ──────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.proUnlockDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        // ── Features grid ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              _FeatureTile(Icons.history_rounded, l10n.proFeatureHistory),
              _FeatureTile(Icons.favorite_rounded, l10n.proFeatureFavorites),
              _FeatureTile(Icons.bar_chart_rounded, l10n.analyticsTitle),
              _FeatureTile(Icons.people_rounded, l10n.gameModeLocal),
              _FeatureTile(Icons.tag_rounded, l10n.proFeatureNumber),
              _FeatureTile(Icons.palette_rounded, l10n.proFeatureGames),
            ],
          ),
        ),

        // ── IAP state ─────────────────────────────────────────────────────
        if (!premium.isAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppStyles.glassCard(context),
              child: Text(
                l10n.proIapUnavailable,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

        if (premium.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),

        // ── Buy button ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: canBuy
                  ? const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFAB47BC)],
                    )
                  : null,
              color: canBuy ? null : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: canBuy ? () => context.read<PremiumStore>().buyLifetime() : null,
              child: Text(
                '${l10n.proLifetimeTitle} · $price',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Legal ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Text(
            '${l10n.proPrivacyNote}\n${l10n.proPaymentsNote}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feature tile ──────────────────────────────────────────────────────────────

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureTile(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.proPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.proPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

