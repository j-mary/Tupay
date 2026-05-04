/// A simple utility to convert between different fiat currencies.
class CurrencyConverter {
  /// Static base conversion rates relative to USD.
  static const Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.74,
    'NGN': 1378.0,
    'RMB': 6.83,
  };

  /// Converts an amount from one currency to another.
  /// Throws an [ArgumentError] if the currency is not supported.
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (!_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
      throw ArgumentError('Unsupported currency provided');
    }

    final double amountInUsd = amount / _rates[fromCurrency]!;
    final double convertedAmount = amountInUsd * _rates[toCurrency]!;

    // Return truncated to 2 decimal places to avoid floating point inaccuracies
    return (convertedAmount * 100).roundToDouble() / 100;
  }
}
