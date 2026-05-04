import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
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
      body: asyncState.isLoading || state is DashboardLoading
          ? const Center(child: CircularProgressIndicator())
          : state is DashboardError
          ? Center(child: Text('Error: ${state.errorMessage}'))
          : state is DashboardLoaded
          ? RefreshIndicator(
              onRefresh: () =>
                  ref.read(dashboardProvider.notifier).fetchDashboardData(),
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
                          _buildQuickAction(
                            context,
                            'Fund',
                            Icons.add,
                            AppColors.actionFundBg,
                            () {},
                          ),
                          _buildQuickAction(
                            context,
                            'Pay',
                            Icons.payment,
                            AppColors.actionPayBg,
                            () {
                              ref
                                  .read(transactionProvider.notifier)
                                  .beginTransfer();
                              context.goNamed('transfer_config');
                            },
                          ),
                          _buildQuickAction(
                            context,
                            'Swap',
                            Icons.swap_horiz,
                            AppColors.actionSwapBg,
                            () {},
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
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          _WalletCard(
                            flag: '🇺🇸',
                            currencyCode: 'USD',
                            amount: '\$12,450',
                            country: 'UNITED STATES',
                          ),
                          _WalletCard(
                            flag: '🇨🇦',
                            currencyCode: 'CAD',
                            amount: 'C\$4,200',
                            country: 'CANADA',
                          ),
                          _WalletCard(
                            flag: '🇦🇺',
                            currencyCode: 'AUD',
                            amount: 'A\$3,150',
                            country: 'AUSTRALIA',
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
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.backgroundWhite,
                          child: Icon(
                            tx.isCredit
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: tx.isCredit
                                ? AppColors.successPrimary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        title: Text(
                          tx.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: Text(
                          '${tx.isCredit ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: tx.isCredit
                                ? AppColors.successPrimary
                                : AppColors.textDark,
                          ),
                        ),
                      );
                    }, childCount: state.recentTransactions.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            )
          : const SizedBox.shrink(),
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

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String flag;
  final String currencyCode;
  final String amount;
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
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardStroke),
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
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            country,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textGrey,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
