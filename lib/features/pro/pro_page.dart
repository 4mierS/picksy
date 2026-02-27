import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/premium_store.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumStore>();
    final monthly = premium.productById(PremiumStore.monthlyId);
    final lifetime = premium.productById(PremiumStore.lifetimeId);
    final canBuyMonthly =
        premium.isAvailable &&
        !premium.isLoading &&
        !premium.isPro &&
        monthly != null;

    final canBuyLifetime =
        premium.isAvailable &&
        !premium.isLoading &&
        !premium.isPro &&
        lifetime != null;
    final monthlyPrice = monthly?.price ?? '€0.49 / month';
    final lifetimePrice = lifetime?.price ?? '€7.49 one-time';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text(
                'Go Pro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Chip(label: Text(premium.isPro ? 'PRO ACTIVE' : 'FREE')),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            premium.isPro
                ? 'Thanks! Pro is active on this device.'
                : 'Unlock Pro features: more history, unlimited favorites, and advanced generators.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          const SizedBox(height: 16),

          _FeatureCard(
            title: 'What you get with Pro',
            children: const [
              _Bullet('History: 50 results (Free: 3)'),
              _Bullet('Unlimited favorites (Free: 2)'),
              _Bullet('Number: custom min/max + float + even/odd'),
              _Bullet('Color: palette + modes + contrast'),
              _Bullet('Letter: lowercase + umlauts + vowels + exclude'),
              _Bullet('Custom List: undo + weighted (V1)'),
              _Bullet('Bottle Spin: strength + haptics'),
              _Bullet('Workflow builder: unlimited fields'),
            ],
          ),

          const SizedBox(height: 16),

          _SectionTitle('Choose your plan'),
          const SizedBox(height: 10),

          // Monthly plan
          _PlanTile(
            title: 'Pro Monthly',
            price: monthlyPrice,
            subtitle: 'Best if you want to try it out',
            badge: 'POPULAR',
            enabled: canBuyMonthly,
            onPressed: canBuyMonthly
                ? () => context.read<PremiumStore>().buyMonthly()
                : null,
          ),

          const SizedBox(height: 10),

          // Lifetime plan
          _PlanTile(
            title: 'Lifetime Unlock',
            price: lifetimePrice,
            subtitle: 'Pay once, keep Pro forever',
            enabled: canBuyLifetime,
            onPressed: canBuyLifetime
                ? () => context.read<PremiumStore>().buyLifetime()
                : null,
          ),

          const SizedBox(height: 16),

          // Restore purchases
          OutlinedButton.icon(
            onPressed: premium.isLoading
                ? null
                : () async {
                    await context.read<PremiumStore>().restore();
                  },
            icon: const Icon(Icons.restore),
            label: const Text('Restore purchases'),
          ),

          const SizedBox(height: 18),

          Text(
            'Privacy: No account required. All data stays on your device.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Note: Payments and restore will be handled via the Apple / Google store account.',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.enabled,
    this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
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
                          fontWeight: FontWeight.w700,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.12),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
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
                      fontWeight: FontWeight.w600,
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
              onPressed: enabled ? onPressed : null,
              child: Text(enabled ? 'Unlock' : 'Active'),
            ),
          ],
        ),
      ),
    );
  }
}
