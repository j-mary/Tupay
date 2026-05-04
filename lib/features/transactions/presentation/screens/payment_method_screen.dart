import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/stepper_component.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(transactionProvider.notifier).backToConfig(),
        ),
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
                      color: Color(0xFF64748B),
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
        context.pushNamed('transfer_review');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF131B2E).withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF191C1E)),
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
                      color: Color(0xFF191C1E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF45464D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
