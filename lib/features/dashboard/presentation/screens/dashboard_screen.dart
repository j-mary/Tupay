import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_state.dart';
import '../widgets/total_balance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).fetchDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dashboardProvider);
    final state = asyncState.asData?.value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.receiptDark,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'T',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Tupay'),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.fieldFill,
              child: Text(
                'AR',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: state is DashboardError
          ? Center(child: Text('Error: ${state.errorMessage}'))
          : Skeletonizer(
              enabled:
                  asyncState.isLoading ||
                  state is DashboardLoading ||
                  state == null,
              child: _DashboardContent(
                state: state is DashboardLoaded ? state : _skeletonDashboard,
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).fetchDashboardData(),
                onPay: () {
                  ref.read(transactionProvider.notifier).beginTransfer();
                  context.goNamed(transferConfigRouteName);
                },
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        selectedItemColor: AppColors.successPrimary,
        unselectedItemColor: AppColors.textGrey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static final _skeletonDashboard = DashboardLoaded(
    totalBalance: 0.0,
    recentTransactions: List.generate(
      6,
      (index) => DashboardTransaction(
        id: 'SKELETON-$index',
        title: 'Loading Transaction...',
        amount: 0.0,
        date: DateTime.now(),
        isCredit: true,
        category: TransactionCategory.funding,
        status: TransactionStatus.success,
      ),
    ),
    totalProcessedTransactions: 0,
  );
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;
  final Future<void> Function() onRefresh;
  final VoidCallback onPay;

  const _DashboardContent({
    required this.state,
    required this.onRefresh,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TotalBalanceCardDelegate(
              totalBalance: state.totalBalance,
              onAddFunds: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    label: 'Fund',
                    icon: Icon(Icons.add, color: AppColors.textDark),
                    bgColor: AppColors.actionFundBg,
                    onTap: () {},
                  ),
                  _QuickAction(
                    label: 'Pay',
                    icon: Image.asset(
                      'assets/png/pay_icon.png',
                      width: 24,
                      height: 24,
                    ),
                    bgColor: AppColors.actionPayBg,
                    onTap: onPay,
                  ),
                  _QuickAction(
                    label: 'Swap',
                    icon: Icon(Icons.swap_horiz, color: AppColors.textDark),
                    bgColor: AppColors.actionSwapBg,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text('Wallets', style: theme.textTheme.titleLarge),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 145,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _WalletCard(
                    flag: '🇳🇬',
                    currencyCode: 'NGN',
                    amount: 1850000,
                    country: 'NIGERIA',
                  ),
                  _WalletCard(
                    flag: '🇨🇳',
                    currencyCode: 'RMB',
                    amount: 31500,
                    country: 'CHINA',
                  ),
                  _WalletCard(
                    flag: '🇺🇸',
                    currencyCode: 'USD',
                    amount: 12450,
                    country: 'UNITED STATES',
                  ),
                  _WalletCard(
                    flag: '🇪🇺',
                    currencyCode: 'EUR',
                    amount: 8700,
                    country: 'EUROPE',
                  ),
                  _WalletCard(
                    flag: '🇬🇧',
                    currencyCode: 'GBP',
                    amount: 4200,
                    country: 'UNITED KINGDOM',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.successPrimary,
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tx = state.recentTransactions[index];
              return _TransactionItem(transaction: tx);
            }, childCount: state.recentTransactions.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 103,
        height: 112,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: icon,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String flag;
  final String currencyCode;
  final double amount;
  final String country;

  const _WalletCard({
    required this.flag,
    required this.currencyCode,
    required this.amount,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardStroke),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundOffWhite,
                  shape: BoxShape.circle,
                ),
                child: Text(flag, style: theme.textTheme.labelMedium),
              ),
              const SizedBox(width: 8),
              Text(
                currencyCode,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          CurrencyText(
            amount: amount,
            currencyCode: currencyCode,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textHeading,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            country,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.iconMuted,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final DashboardTransaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color iconBgColor;
    Widget icon;

    switch (transaction.category) {
      case TransactionCategory.funding:
        iconBgColor = AppColors.actionFundBg;
        icon = const Icon(Icons.add, color: AppColors.successPrimary, size: 20);
        break;
      case TransactionCategory.transfer:
        iconBgColor = AppColors.actionPayBg;
        icon = const Icon(
          Icons.send,
          color: AppColors.totalBalanceCardBg,
          size: 20,
        );
        break;
      case TransactionCategory.cardPayment:
        iconBgColor = AppColors.actionSwapBg;
        icon = const Icon(
          Icons.credit_card,
          color: AppColors.totalBalanceCardBg,
          size: 20,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: icon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textHeading,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (transaction.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.subtitle} • 2m ago',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: transaction.isCredit
                    ? transaction.amount
                    : -transaction.amount,
                currencyCode: 'USD',
                showSign: true,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: transaction.isCredit
                      ? AppColors.successPrimary
                      : AppColors.textHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.actionFundBg.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Success',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.successPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
