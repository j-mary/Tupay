import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/isolate/transaction_parser.dart';

void main() {
  test(
    'Background parser should correctly filter transactions from a predictable large-scale mock payload',
    () async {
      final first = MockTransactionPayloadGenerator.generateLargeJson(
        targetSizeBytes: 20000,
      );
      final second = MockTransactionPayloadGenerator.generateLargeJson(
        targetSizeBytes: 20000,
      );

      expect(first, second);
      expect(first.length, greaterThanOrEqualTo(20000));

      final parsed = await TransactionParser.parseLargeJsonBackground(
        first,
        visibleLimit: 6,
      );

      expect(parsed, hasLength(6));
      expect(parsed.every((transaction) => transaction.amount > 0), isTrue);
    },
  );
}
