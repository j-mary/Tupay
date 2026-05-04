import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/core/navigation/app_router.dart';
import 'package:tupay_app/core/theme/app_colors.dart';
import 'package:tupay_app/core/utils/currency_converter.dart';
import 'package:tupay_app/core/utils/currency_formatter.dart';
import 'package:tupay_app/core/widgets/currency_text.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/jagged_receipt_edge.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/stepper_component.dart';

class TransferSummaryScreen extends ConsumerWidget {
  const TransferSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<TransactionState>>(transactionProvider, (
      previous,
      next,
    ) {
      final nextState = next.asData?.value;
      final previousState = previous?.asData?.value;
      if (nextState is TransactionSuccess &&
          previousState is! TransactionSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showSuccessDialog(context, ref);
          }
        });
      } else if (nextState is TransactionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextState.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final state =
        ref.watch(transactionProvider).asData?.value ??
        TransactionState.initial();
    final transaction = state.transaction;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.transferBackground,
      appBar: AppBar(
        title: const Text('Review Transfer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(transactionProvider.notifier).backToPaymentMethod();
            context.goNamed(paymentMethodRouteName);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(transactionProvider.notifier).reset();
              context.goNamed(dashboardRouteName);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: StepperComponent(
                currentStep: 2,
                steps: ['Amount', 'Payment', 'Review'],
              ),
            ),
            Expanded(
              child: ListView(
                key: const PageStorageKey('transfer_review_scroll'),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildSectionTitle('RECIPIENT'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: transaction.recipient.fullName,
                    subtitle: transaction.recipient.accountNumber,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('PAYMENT METHOD'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: transaction.paymentMethod ?? 'Not Selected',
                    subtitle: 'Secure Payment',
                    icon: Icons.payment,
                  ),
                  const SizedBox(height: 32),
                  _buildDetailedSummaryCard(theme, transaction),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, state),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.mutedText,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.fieldFill,
            child: Icon(icon, color: AppColors.receiptDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSummaryCard(ThemeData theme, var transaction) {
    const cardColor = AppColors.receiptDark;
    final recipientAmount = CurrencyConverter.convert(
      amount: transaction.amount,
      fromCurrency: transaction.currency.code,
      toCurrency: transaction.recipientCurrency.code,
    );
    final sourceUnit = CurrencyFormatter.format(
      amount: 1,
      code: transaction.currency.code,
      symbol: transaction.currency.symbol,
    );
    final targetUnit = CurrencyFormatter.format(
      amount: CurrencyConverter.convert(
        amount: 1,
        fromCurrency: transaction.currency.code,
        toCurrency: transaction.recipientCurrency.code,
      ),
      code: transaction.recipientCurrency.code,
      symbol: transaction.recipientCurrency.symbol,
    );
    return Column(
      children: [
        const JaggedReceiptEdge(color: cardColor, isTop: true),
        Container(
          padding: const EdgeInsets.all(24),
          color: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transfer Details',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryItem(
                'Sending Amount',
                CurrencyFormatter.format(
                  amount: transaction.amount,
                  code: transaction.currency.code,
                  symbol: transaction.currency.symbol,
                ),
              ),
              _buildSummaryItem('Exchange Rate', '$sourceUnit = $targetUnit'),
              _buildSummaryItem(
                'Recipient Gets',
                CurrencyFormatter.format(
                  amount: recipientAmount,
                  code: transaction.recipientCurrency.code,
                  symbol: transaction.recipientCurrency.symbol,
                ),
              ),
              _buildSummaryItem(
                'Fees',
                CurrencyFormatter.format(
                  amount: transaction.fee,
                  code: transaction.currency.code,
                  symbol: transaction.currency.symbol,
                ),
                isPromo: transaction.fee == 0,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(color: AppColors.receiptDivider),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL TO PAY',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      letterSpacing: 1.6,
                    ),
                  ),
                  CurrencyText(
                    amount: transaction.totalToPay,
                    currencyCode: transaction.currency.code,
                    currencySymbol: transaction.currency.symbol,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const JaggedReceiptEdge(color: cardColor, isTop: false),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isPromo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(
            value,
            style: TextStyle(
              color: isPromo
                  ? AppColors.successGreenLight
                  : AppColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    TransactionState state,
  ) {
    final isProcessing = state is TransactionProcessing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isProcessing
            ? null
            : () {
                ref.read(transactionProvider.notifier).submitTransaction();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successPrimary,
          foregroundColor: AppColors.textWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'REVIEW & SEND',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(
              Icons.check_circle,
              color: AppColors.successPrimary,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Transfer Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your money is on its way.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(transactionProvider.notifier).reset();
                context.goNamed(dashboardRouteName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successPrimary,
                foregroundColor: AppColors.textWhite,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
