import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/utils/currency_formatter.dart';

void main() {
  test('formats currency with symbol and two decimal places', () {
    expect(
      CurrencyFormatter.format(amount: 100000, code: 'GBP'),
      '£100,000.00',
    );
    expect(CurrencyFormatter.format(amount: 2500.5, code: 'NGN'), '₦2,500.50');
  });

  test('formats signed currency values', () {
    expect(
      CurrencyFormatter.format(amount: 1000, code: 'USD', showSign: true),
      '+\$1,000.00',
    );
    expect(
      CurrencyFormatter.format(amount: -1000, code: 'USD', showSign: true),
      '-\$1,000.00',
    );
  });
}
