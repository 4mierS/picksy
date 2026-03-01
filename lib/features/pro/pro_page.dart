import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';

import '../../storage/premium_store.dart';
import '../../core/ui/app_styles.dart';
import '../../core/ui/app_colors.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  final _promoController = TextEditingController();
  bool _promoLoading = false;
  String? _promoMessage;
  bool _promoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final l10n = context.l10n;
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _promoLoading = true;
      _promoMessage = null;
    });

    final success = await context.read<PremiumStore>().redeemPromoCode(code);

    if (!mounted) return;
    setState(() {
      _promoLoading = false;
      _promoSuccess = success;
      _promoMessage = success ? l10n.proPromoCodeSuccess : l10n.proPromoCodeInvalid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final premium = context.watch<PremiumStore>();

    //final monthly = premium.productById(PremiumStore.monthlyId);
    final lifetime = premium.productById(PremiumStore.lifetimeId);

    // final canBuyMonthly = premium.isAvailable && !premium.isLoading && !premium.isPro && monthly != null;

    final canBuyLifetime =
        premium.isAvailable &&
        !premium.isLoading &&
        !premium.isPro &&
        lifetime != null;

    // final monthlyPrice = monthly?.price ?? l10n.proMonthlyFallbackPrice;
    final lifetimePrice = lifetime?.price ?? l10n.proLifetimeFallbackPrice;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                l10n.proGoPro,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.proPurple.withOpacity(0.95),
                      AppColors.proPurple.withOpacity(0.75),
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
            ],
          ),
          const SizedBox(height: 12),

          Text(
            premium.isPro ? l10n.proThanksActive : l10n.proUnlockDescription,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          const SizedBox(height: 14),

          if (!premium.isAvailable)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppStyles.glassCard(context),
              child: Text(l10n.proIapUnavailable),
            ),

          if (premium.isLoading && !premium.isPro) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],

          const SizedBox(height: 16),

          _FeatureCard(
            title: l10n.proWhatYouGet,
            children: [
              _Bullet(l10n.proFeatureHistory),
              _Bullet(l10n.proFeatureFavorites),
              _Bullet(l10n.proFeatureNumber),
              _Bullet(l10n.proFeatureColor),
              _Bullet(l10n.proFeatureLetter),
              _Bullet(l10n.proFeatureCustomList),
              _Bullet(l10n.proFeatureBottleSpin),
            ],
          ),

          const SizedBox(height: 16),

          _SectionTitle(l10n.proChoosePlan),
          const SizedBox(height: 10),

          // _PlanTile(
          //   title: l10n.proMonthlyTitle,
          //   price: monthlyPrice,
          //   subtitle: l10n.proMonthlySubtitle,
          //   badge: l10n.proPopular,
          //   enabled: canBuyMonthly,
          //   decoration: AppStyles.gradientCard(AppColors.proPurple),
          //   onPressed: canBuyMonthly
          //       ? () => context.read<PremiumStore>().buyMonthly()
          //       : null,
          // ),
          const SizedBox(height: 10),

          _PlanTile(
            title: l10n.proLifetimeTitle,
            price: lifetimePrice,
            subtitle: l10n.proLifetimeSubtitle,
            enabled: canBuyLifetime,
            decoration: AppStyles.gradientCard(AppColors.proPurple),
            onPressed: canBuyLifetime
                ? () => context.read<PremiumStore>().buyLifetime()
                : null,
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: premium.isLoading
                ? null
                : () => context.read<PremiumStore>().restore(),
            icon: const Icon(Icons.restore),
            label: Text(l10n.proRestorePurchases),
          ),

          if (!premium.isPro) ...[
            const SizedBox(height: 16),
            _PromoCodeInput(
              controller: _promoController,
              loading: _promoLoading,
              message: _promoMessage,
              success: _promoSuccess,
              onApply: _applyPromo,
            ),
          ],

          const SizedBox(height: 18),

          Text(
            l10n.proPrivacyNote,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.proPaymentsNote,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FeatureCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.glassCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool enabled;
  final VoidCallback? onPressed;
  final BoxDecoration? decoration;

  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.enabled,
    this.onPressed,
    this.badge,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: decoration ?? AppStyles.glassCard(context),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: AppColors.proPurple.withOpacity(0.12),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.proPurple,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.proPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: enabled ? onPressed : null,
              child: Text(
                enabled ? l10n.proUnlockButton : l10n.proActiveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final String? message;
  final bool success;
  final VoidCallback onApply;

  const _PromoCodeInput({
    required this.controller,
    required this.loading,
    required this.message,
    required this.success,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proPromoCode,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: l10n.proPromoCodeHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onApply(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.proPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: loading ? null : onApply,
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.proPromoCodeApply),
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            style: TextStyle(
              color: success ? Colors.green : Colors.red,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
