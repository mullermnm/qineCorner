import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qine_corner/common/widgets/app_text.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/features/subscription/domain/subscription_model.dart';
import 'package:qine_corner/features/subscription/providers/subscription_provider.dart';

class SubscriptionStatusWidget extends ConsumerWidget {
  final bool showUpgradeButton;
  final VoidCallback? onUpgrade;

  const SubscriptionStatusWidget({
    Key? key,
    this.showUpgradeButton = true,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumStatusAsync = ref.watch(subscriptionNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return premiumStatusAsync.when(
      data: (status) => _buildStatusCard(context, status, isDark),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorWidget(context, error, isDark),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, SubscriptionStatus status, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              status.isPremium ? Colors.amber.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isPremium
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: status.isPremium ? Colors.amber : null,
                  size: 28,
                ),
                const SizedBox(width: 8),
                AppText.h2(
                  status.isPremium ? 'Premium Member' : 'Free Account',
                  color: status.isPremium ? Colors.amber : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (status.isPremium && status.expiryDate != null) ...[
              AppText.body(
                'Your premium subscription is active until:',
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                bold: false,
              ),
              const SizedBox(height: 4),
              AppText.body(
                DateFormat('MMMM d, yyyy').format(status.expiryDate!),
                bold: true,
              ),
              const SizedBox(height: 16),
            ],
            if (!status.isPremium && showUpgradeButton)
              ElevatedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.upgrade),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            if (status.isPremium && showUpgradeButton)
              OutlinedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.refresh),
                label: const Text('Renew Subscription'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                AppText.h2('Subscription Error'),
              ],
            ),
            const SizedBox(height: 8),
            AppText.body(
              'Unable to load subscription status: ${error.toString()}',
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              bold: true,
            ),
            const SizedBox(height: 16),
            if (showUpgradeButton)
              ElevatedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
