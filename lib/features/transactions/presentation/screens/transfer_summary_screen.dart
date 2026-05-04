import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/jagged_receipt_edge.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/stepper_component.dart';

class TransferSummaryScreen extends ConsumerWidget {
  const TransferSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next is TransactionSuccess) {
        _showSuccessDialog(context, ref);
      } else if (next is TransactionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(transactionProvider);
    final transaction = state.transaction;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Review Transfer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              ref.read(transactionProvider.notifier).backToPaymentMethod(),
        ),
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
        color: Color(0xFF64748B),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F5F9),
            child: Icon(icon, color: const Color(0xFF131B2E), size: 20),
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
                    color: Color(0xFF64748B),
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
    const cardColor = Color(0xFF131B2E);
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
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryItem(
                'Sending Amount',
                '${transaction.amount.toStringAsFixed(2)} ${transaction.currency.code}',
              ),
              _buildSummaryItem('Exchange Rate', '1 USD = 0.9245 EUR'),
              _buildSummaryItem('Recipient Gets', '924.50 EUR'),
              _buildSummaryItem('Fees', '0.00 USD', isPromo: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(color: Color(0xFF3F465C)),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL TO PAY',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C839B),
                      letterSpacing: 1.6,
                    ),
                  ),
                  Text(
                    '1,000.00 USD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
          Text(label, style: const TextStyle(color: Color(0xFF7C839B))),
          Text(
            value,
            style: TextStyle(
              color: isPromo ? const Color(0xFF6FFBBE) : Colors.white,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          backgroundColor: const Color(0xFF006C49),
          foregroundColor: Colors.white,
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
                  color: Colors.white,
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
            const Icon(Icons.check_circle, color: Color(0xFF006C49), size: 64),
            const SizedBox(height: 24),
            const Text(
              'Transfer Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your money is on its way.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(transactionProvider.notifier).reset();
                context.goNamed('dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006C49),
                foregroundColor: Colors.white,
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
