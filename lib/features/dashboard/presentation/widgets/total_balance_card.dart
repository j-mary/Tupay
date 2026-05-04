import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/currency_text.dart';

class TotalBalanceCardDelegate extends SliverPersistentHeaderDelegate {
  final double totalBalance;
  final bool isBalanceHidden;
  final VoidCallback onAddFunds;
  final VoidCallback onToggleBalanceVisibility;

  TotalBalanceCardDelegate({
    required this.totalBalance,
    required this.isBalanceHidden,
    required this.onAddFunds,
    required this.onToggleBalanceVisibility,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundOffWhite,
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.totalBalanceCardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textWhite),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successOverlay,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: AppColors.successGreenLight,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+ 2.4%',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onToggleBalanceVisibility,
                      tooltip: isBalanceHidden
                          ? 'Show balance'
                          : 'Hide balance',
                      icon: Icon(
                        isBalanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.successOverlay,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            CurrencyText(
              amount: totalBalance,
              currencyCode: 'USD',
              isHidden: isBalanceHidden,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Spacer(),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onAddFunds,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Funds'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundWhite,
                    foregroundColor: AppColors.totalBalanceCardBg,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textWhite),
                    foregroundColor: AppColors.textWhite,
                  ),
                  child: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 260.0;

  @override
  double get minExtent => 260.0;

  @override
  bool shouldRebuild(covariant TotalBalanceCardDelegate oldDelegate) {
    return oldDelegate.totalBalance != totalBalance ||
        oldDelegate.isBalanceHidden != isBalanceHidden;
  }
}
