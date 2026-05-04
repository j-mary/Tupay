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
  bool _isBalanceHidden = false;
  bool _showScrollToTop = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    final dashboardState = ref.read(dashboardProvider);
    if (!dashboardState.hasValue) {
      Future.microtask(
        () => ref.read(dashboardProvider.notifier).fetchDashboardData(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final shouldShow = position.pixels > 180;

    if (shouldShow == _showScrollToTop) return;

    setState(() {
      _showScrollToTop = shouldShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dashboardProvider);
    final state = asyncState.asData?.value;

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
                isBalanceHidden: _isBalanceHidden,
                scrollController: _scrollController,
                onToggleBalanceVisibility: () {
                  setState(() {
                    _isBalanceHidden = !_isBalanceHidden;
                  });
                },
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).fetchDashboardData(),
                onPay: () {
                  ref.read(transactionProvider.notifier).beginTransfer();
                  context.goNamed(transferConfigRouteName);
                },
              ),
            ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              },
              backgroundColor: AppColors.successPrimary,
              foregroundColor: AppColors.textWhite,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _DashboardBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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

class _DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DashboardBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.fieldFill, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              label: 'HOME',
              iconPath: 'assets/png/home_icon.png',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _BottomNavItem(
              label: 'CARDS',
              iconPath: 'assets/png/cards_icon.png',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _BottomNavItem(
              label: 'TRANSFER',
              iconPath: 'assets/png/transfer_icon.png',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _BottomNavItem(
              label: 'PROFILE',
              iconPath: 'assets/png/profile_icon.png',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.successPrimary : AppColors.iconMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;
  final bool isBalanceHidden;
  final ScrollController scrollController;
  final VoidCallback onToggleBalanceVisibility;
  final Future<void> Function() onRefresh;
  final VoidCallback onPay;

  const _DashboardContent({
    required this.state,
    required this.isBalanceHidden,
    required this.scrollController,
    required this.onToggleBalanceVisibility,
    required this.onRefresh,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TotalBalanceCardDelegate(
              totalBalance: state.totalBalance,
              isBalanceHidden: isBalanceHidden,
              onToggleBalanceVisibility: onToggleBalanceVisibility,
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
                    icon: Image.asset(
                      'assets/png/transfer_icon.png',
                      width: 24,
                      height: 24,
                      color: AppColors.textDark,
                    ),
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
                children: [
                  _WalletCard(
                    flag: '🇳🇬',
                    currencyCode: 'NGN',
                    amount: 1850000,
                    country: 'NIGERIA',
                    isBalanceHidden: isBalanceHidden,
                  ),
                  _WalletCard(
                    flag: '🇨🇳',
                    currencyCode: 'RMB',
                    amount: 31500,
                    country: 'CHINA',
                    isBalanceHidden: isBalanceHidden,
                  ),
                  _WalletCard(
                    flag: '🇺🇸',
                    currencyCode: 'USD',
                    amount: 12450,
                    country: 'UNITED STATES',
                    isBalanceHidden: isBalanceHidden,
                  ),
                  _WalletCard(
                    flag: '🇪🇺',
                    currencyCode: 'EUR',
                    amount: 8700,
                    country: 'EUROPE',
                    isBalanceHidden: isBalanceHidden,
                  ),
                  _WalletCard(
                    flag: '🇬🇧',
                    currencyCode: 'GBP',
                    amount: 4200,
                    country: 'UNITED KINGDOM',
                    isBalanceHidden: isBalanceHidden,
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
              return _TransactionItem(
                transaction: tx,
                isBalanceHidden: isBalanceHidden,
              );
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
  final bool isBalanceHidden;

  const _WalletCard({
    required this.flag,
    required this.currencyCode,
    required this.amount,
    required this.country,
    required this.isBalanceHidden,
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
            isHidden: isBalanceHidden,
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
  final bool isBalanceHidden;

  const _TransactionItem({
    required this.transaction,
    required this.isBalanceHidden,
  });

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
                isHidden: isBalanceHidden,
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
