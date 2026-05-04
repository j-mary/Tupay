import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Removed unused import
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/jagged_receipt_edge.dart';
import 'package:tupay_app/features/transactions/presentation/widgets/stepper_component.dart';

class TransferConfigScreen extends ConsumerStatefulWidget {
  const TransferConfigScreen({super.key});

  @override
  ConsumerState<TransferConfigScreen> createState() =>
      _TransferConfigScreenState();
}

class _TransferConfigScreenState extends ConsumerState<TransferConfigScreen> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    final transaction = ref.read(transactionProvider).transaction;
    _amountController = TextEditingController(
      text: transaction.amount > 0 ? transaction.amount.toString() : '',
    );
    _nameController = TextEditingController(
      text: transaction.recipient.fullName,
    );
    _accountController = TextEditingController(
      text: transaction.recipient.accountNumber,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(transactionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          'Tupay',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF131B2E),
              child: const Icon(
                Icons.person_outline,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: StepperComponent(
                  currentStep: 0,
                  steps: ['Amount', 'Payment', 'Review'],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionTitle('SEND MONEY'),
                  const SizedBox(height: 16),
                  _buildAmountCard(theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle('RECIPIENT DETAILS'),
                  const SizedBox(height: 16),
                  _buildRecipientForm(theme),
                  const SizedBox(height: 32),
                  _buildSummaryCard(theme),
                  const SizedBox(height: 32),
                  _buildTrustBadge(theme),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
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

  Widget _buildAmountCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrencyInput('You Send', 'USD', true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          _buildCurrencyInput('Recipient Gets', 'EUR', false),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput(String label, String currency, bool isEditable) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              isEditable
                  ? TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : const Text(
                      '924.50',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                currency,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountController,
            decoration: const InputDecoration(
              labelText: 'IBAN / Account Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
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
              Text(
                'Transfer Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryItem('Sending', '1,000.00 USD'),
              _buildSummaryItem('Fees', '0.00 USD (Promo)', isPromo: true),
              _buildSummaryItem('Estimated Arrival', 'Today, ~15 mins'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(color: Color(0xFF3F465C)),
              ),
              const Text(
                'TOTAL TO PAY',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C839B),
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1,000.00 USD',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
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

  Widget _buildTrustBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC6C6CD).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF006C49)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'End-to-End Encryption',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Your transaction is protected by bank-grade security protocols.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF45464D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
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
        onPressed: () {
          // Update state
          ref
              .read(transactionProvider.notifier)
              .updateAmount(double.tryParse(_amountController.text) ?? 0.0);
          ref
              .read(transactionProvider.notifier)
              .updateRecipient(
                Recipient(
                  fullName: _nameController.text,
                  accountNumber: _accountController.text,
                ),
              );

          // Proceed and navigate
          ref.read(transactionProvider.notifier).proceedToPaymentMethod();
          context.pushNamed('payment_method');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006C49),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'CONTINUE',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
