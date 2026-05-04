class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, String> symbols = {
    'NGN': '₦',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'RMB': '¥',
  };

  static String format({
    required double amount,
    required String code,
    String? symbol,
    bool showSign = false,
  }) {
    final resolvedSymbol = symbol ?? symbols[code] ?? code;
    final sign = amount < 0
        ? '-'
        : showSign && amount > 0
        ? '+'
        : '';
    final absolute = amount.abs().toStringAsFixed(2);
    final parts = absolute.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      final remaining = whole.length - i;
      buffer.write(whole[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return '$sign$resolvedSymbol$buffer.${parts.last}';
  }
}
