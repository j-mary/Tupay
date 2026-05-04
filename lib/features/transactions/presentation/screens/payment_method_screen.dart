import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/core/navigation/app_router.dart';
import 'package:tupay_app/core/theme/app_colors.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/stepper_component.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: AppColors.transferBackground,
      appBar: AppBar(
        title: const Text('Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(transactionProvider.notifier).backToConfig();
            context.goNamed(transferConfigRouteName);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.goNamed(dashboardRouteName);
              Future.microtask(
                () => ref.read(transactionProvider.notifier).reset(),
              );
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
                currentStep: 1,
                steps: ['Amount', 'Payment', 'Review'],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  const Text(
                    'SELECT PAYMENT METHOD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentButton(
                    context,
                    ref,
                    'Apple Pay',
                    'Fast and secure',
                    Icons.phone_iphone,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentButton(
                    context,
                    ref,
                    'Debit / Credit Card',
                    'Visa, Mastercard, etc.',
                    Icons.credit_card,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentButton(
                    context,
                    ref,
                    'Google Pay',
                    'Pay with Google account',
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        ref.read(transactionProvider.notifier).selectPaymentMethod(title);
        context.goNamed(transferReviewRouteName);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.receiptDark.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.textDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.supportingText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}
