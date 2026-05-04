import 'package:flutter/material.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/currency_text.dart';

class TotalBalanceCardDelegate extends SliverPersistentHeaderDelegate {
  final double totalBalance;
  final bool isBalanceHidden;
  final VoidCallback onToggleBalanceVisibility;

  TotalBalanceCardDelegate({
    required this.totalBalance,
    required this.isBalanceHidden,
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
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              currencyCode: Currency.ngn.code,
              isHidden: isBalanceHidden,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 36,
                height: 1.05,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successOverlay,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    color: AppColors.successGreenLight,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text('+ 2.4%', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(width: 6),
                  Text(
                    'vs last month',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.72),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      letterSpacing: 0,
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

  @override
  double get maxExtent => 220.0;

  @override
  double get minExtent => 220.0;

  @override
  bool shouldRebuild(covariant TotalBalanceCardDelegate oldDelegate) {
    return oldDelegate.totalBalance != totalBalance ||
        oldDelegate.isBalanceHidden != isBalanceHidden;
  }
}
