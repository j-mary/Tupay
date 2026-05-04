/// Represents a currency with its code and symbol.
class Currency {
  final String code;
  final String symbol;

  const Currency({
    required this.code,
    required this.symbol,
  });

  static const usd = Currency(code: 'USD', symbol: '\$');
  static const eur = Currency(code: 'EUR', symbol: '€');
  static const gbp = Currency(code: 'GBP', symbol: '£');
  static const rmb = Currency(code: 'RMB', symbol: '¥');
}

/// Represents the recipient of a transaction.
class Recipient {
  final String fullName;
  final String accountNumber;
  final String? bankName;

  const Recipient({
    required this.fullName,
    required this.accountNumber,
    this.bankName,
  });

  const Recipient.empty()
      : fullName = '',
        accountNumber = '',
        bankName = null;

  bool get isEmpty => fullName.isEmpty && accountNumber.isEmpty;
}

/// Represents a transaction in progress.
class Transaction {
  final double amount;
  final Currency currency;
  final Recipient recipient;
  final String? paymentMethod;
  final double fee;
  final DateTime? estimatedArrival;

  const Transaction({
    required this.amount,
    required this.currency,
    required this.recipient,
    this.paymentMethod,
    this.fee = 0.0,
    this.estimatedArrival,
  });

  Transaction copyWith({
    double? amount,
    Currency? currency,
    Recipient? recipient,
    String? paymentMethod,
    double? fee,
    DateTime? estimatedArrival,
  }) {
    return Transaction(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipient: recipient ?? this.recipient,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fee: fee ?? this.fee,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
    );
  }

  double get totalToPay => amount + fee;
}
