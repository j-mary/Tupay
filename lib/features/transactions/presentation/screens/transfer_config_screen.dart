import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/core/utils/amount_input_formatter.dart';
import 'package:tupay_app/core/navigation/app_router.dart';
import 'package:tupay_app/core/theme/app_colors.dart';
import 'package:tupay_app/core/utils/currency_converter.dart';
import 'package:tupay_app/core/utils/currency_formatter.dart';
import 'package:tupay_app/core/widgets/currency_text.dart';
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
  late FocusNode _amountFocusNode;
  late Transaction _draftTransaction;
  String? _validationMessage;
  static const _currencies = [
    Currency.ngn,
    Currency.usd,
    Currency.eur,
    Currency.gbp,
    Currency.rmb,
  ];

  @override
  void initState() {
    super.initState();
    final transaction =
        ref.read(transactionProvider).asData?.value.transaction ??
        TransactionState.initial().transaction;
    _draftTransaction = transaction;
    _amountController = TextEditingController(
      text: transaction.amount > 0 ? transaction.amount.toString() : '',
    );
    _nameController = TextEditingController(
      text: transaction.recipient.fullName,
    );
    _accountController = TextEditingController(
      text: transaction.recipient.accountNumber,
    );
    _amountFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.transferBackground,
      appBar: AppBar(
        title: Text(
          'Tupay',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelTransfer,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.receiptDark,
              child: const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.textWhite,
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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _amountController,
                    builder: (context, value, child) {
                      return _buildAmountCard(
                        theme,
                        _draftTransaction.copyWith(amount: _enteredAmount),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('RECIPIENT DETAILS'),
                  const SizedBox(height: 16),
                  _buildRecipientForm(theme),
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildValidationMessage(_validationMessage!),
                  ],
                  const SizedBox(height: 32),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _amountController,
                    builder: (context, value, child) {
                      return _buildSummaryCard(
                        theme,
                        _draftTransaction.copyWith(amount: _enteredAmount),
                      );
                    },
                  ),
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

  double get _enteredAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

  void _syncAmount(String value) {
    if (_validationMessage == null) return;
    setState(() {
      _validationMessage = null;
    });
  }

  void _cancelTransfer() {
    context.goNamed(dashboardRouteName);
    Future.microtask(() => ref.read(transactionProvider.notifier).reset());
  }

  void _updateSendCurrency(Currency currency) {
    setState(() {
      _draftTransaction = _draftTransaction.copyWith(currency: currency);
    });
    ref.read(transactionProvider.notifier).updateCurrency(currency);
  }

  void _updateRecipientCurrency(Currency currency) {
    setState(() {
      _draftTransaction = _draftTransaction.copyWith(
        recipientCurrency: currency,
      );
    });
    ref.read(transactionProvider.notifier).updateRecipientCurrency(currency);
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

  Widget _buildAmountCard(ThemeData theme, Transaction transaction) {
    final recipientAmount = CurrencyConverter.convert(
      amount: transaction.amount,
      fromCurrency: transaction.currency.code,
      toCurrency: transaction.recipientCurrency.code,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrencyInput(
            label: 'You Send',
            currency: transaction.currency,
            amount: transaction.amount,
            isEditable: true,
            onCurrencyChanged: _updateSendCurrency,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          _buildCurrencyInput(
            label: 'Recipient Gets',
            currency: transaction.recipientCurrency,
            amount: recipientAmount,
            isEditable: false,
            onCurrencyChanged: _updateRecipientCurrency,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    required Currency currency,
    required double amount,
    required bool isEditable,
    required ValueChanged<Currency> onCurrencyChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              if (isEditable)
                TextField(
                  key: const ValueKey('send_amount_field'),
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [AmountInputFormatter()],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _syncAmount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                CurrencyText(
                  amount: amount,
                  currencyCode: currency.code,
                  currencySymbol: currency.symbol,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: currency,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              items: _currencies
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option.code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onCurrencyChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationMessage(String message) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.backgroundWhite.withValues(alpha: 0.3),
        ),
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

  Widget _buildSummaryCard(ThemeData theme, Transaction transaction) {
    const cardColor = AppColors.receiptDark;
    final recipientAmount = CurrencyConverter.convert(
      amount: transaction.amount,
      fromCurrency: transaction.currency.code,
      toCurrency: transaction.recipientCurrency.code,
    );
    final sendingText = CurrencyFormatter.format(
      amount: transaction.amount,
      code: transaction.currency.code,
      symbol: transaction.currency.symbol,
    );
    final recipientText = CurrencyFormatter.format(
      amount: recipientAmount,
      code: transaction.recipientCurrency.code,
      symbol: transaction.recipientCurrency.symbol,
    );
    final feeText = CurrencyFormatter.format(
      amount: transaction.fee,
      code: transaction.currency.code,
      symbol: transaction.currency.symbol,
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
              Text(
                'Transfer Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryItem('Sending', sendingText),
              _buildSummaryItem('Recipient Gets', recipientText),
              _buildSummaryItem('Fees', '$feeText (Promo)', isPromo: true),
              _buildSummaryItem('Estimated Arrival', 'Today, ~15 mins'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(color: AppColors.receiptDivider),
              ),
              const Text(
                'TOTAL TO PAY',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              CurrencyText(
                amount: transaction.totalToPay,
                currencyCode: transaction.currency.code,
                currencySymbol: transaction.currency.symbol,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
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

  Widget _buildTrustBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.successPrimary),
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
                    color: AppColors.supportingText,
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
        onPressed: () {
          ref.read(transactionProvider.notifier).updateAmount(_enteredAmount);
          ref
              .read(transactionProvider.notifier)
              .updateRecipient(
                Recipient(
                  fullName: _nameController.text,
                  accountNumber: _accountController.text,
                ),
              );

          final canProceed = ref
              .read(transactionProvider.notifier)
              .proceedToPaymentMethod();
          if (canProceed) {
            context.goNamed(paymentMethodRouteName);
          } else {
            final state = ref.read(transactionProvider).requireValue;
            final message = state is TransactionError
                ? state.message
                : 'Please check the transfer details.';
            setState(() {
              _validationMessage = message;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successPrimary,
          foregroundColor: AppColors.textWhite,
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
