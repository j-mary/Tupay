import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/isolate/transaction_parser.dart';

void main() {
  test(
    'Background parser should sort transactions from a predictable large-scale mock payload',
    () async {
      final first = MockTransactionPayloadGenerator.generateLargeJson(
        targetSizeBytes: 20000,
      );
      final second = MockTransactionPayloadGenerator.generateLargeJson(
        targetSizeBytes: 20000,
      );

      expect(first, second);
      expect(first.length, greaterThanOrEqualTo(20000));

      final parsed = await TransactionParser.parseLargeJsonBackground(first);

      expect(parsed, isNotEmpty);
      expect(parsed, isSortedByCreatedAtDesc);
    },
  );
}

Matcher get isSortedByCreatedAtDesc {
  return predicate<List<ParsedTransaction>>((items) {
    for (var i = 1; i < items.length; i++) {
      if (items[i - 1].createdAt.isBefore(items[i].createdAt)) {
        return false;
      }
    }
    return true;
  }, 'is sorted by createdAt descending');
}
