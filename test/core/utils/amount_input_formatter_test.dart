import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/utils/amount_input_formatter.dart';

void main() {
  const formatter = AmountInputFormatter();

  test('formats whole numbers with thousands separators', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: '500'),
      const TextEditingValue(text: '5000'),
    );

    expect(result.text, '5,000');
  });

  test('preserves decimal entry up to two places', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: '5000.1'),
      const TextEditingValue(text: '5000.12'),
    );

    expect(result.text, '5,000.12');
  });

  test('rejects more than two decimal places', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: '5,000.12'),
      const TextEditingValue(text: '5,000.123'),
    );

    expect(result.text, '5,000.12');
  });
}
