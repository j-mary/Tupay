import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/utils/currency_converter.dart';

void main() {
  group('CurrencyConverter Tests', () {
    test('converts USD to EUR correctly', () {
      final result = CurrencyConverter.convert(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      expect(result, 85.0);
    });

    test('converts EUR to USD correctly', () {
      final result = CurrencyConverter.convert(
        amount: 85.0,
        fromCurrency: 'EUR',
        toCurrency: 'USD',
      );
      expect(result, 100.0);
    });

    test('converts GBP to NGN correctly', () {
      final result = CurrencyConverter.convert(
        amount: 10.0,
        fromCurrency: 'GBP',
        toCurrency: 'NGN',
      );
      // 10 GBP -> (10 / 0.74) USD -> (13.5135...) * 1378 NGN -> 18621.62
      expect(result, 18621.62);
    });

    test('converts USD to RMB correctly', () {
      final result = CurrencyConverter.convert(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'RMB',
      );
      expect(result, 683.0);
    });

    test('throws ArgumentError for unsupported currency', () {
      expect(
        () => CurrencyConverter.convert(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'YEN',
        ),
        throwsArgumentError,
      );
    });
  });
}
