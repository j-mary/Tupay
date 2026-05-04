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

  Map<String, dynamic> toJson() => {
        'code': code,
        'symbol': symbol,
      };

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      symbol: json['symbol'] as String,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'accountNumber': accountNumber,
        'bankName': bankName,
      };

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      fullName: json['fullName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      bankName: json['bankName'] as String?,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency.toJson(),
        'recipient': recipient.toJson(),
        'paymentMethod': paymentMethod,
        'fee': fee,
        'estimatedArrival': estimatedArrival?.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] != null
          ? Currency.fromJson(Map<String, dynamic>.from(json['currency']))
          : Currency.usd,
      recipient: json['recipient'] != null
          ? Recipient.fromJson(Map<String, dynamic>.from(json['recipient']))
          : const Recipient.empty(),
      paymentMethod: json['paymentMethod'] as String?,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.tryParse(json['estimatedArrival'] as String)
          : null,
    );
  }
}
