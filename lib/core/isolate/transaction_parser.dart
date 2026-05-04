import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

/// Represents a simple parsed transaction.
class ParsedTransaction {
  final String id;
  final double amount;
  final String status;

  ParsedTransaction({
    required this.id,
    required this.amount,
    required this.status,
  });

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) {
    return ParsedTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}

class MockTransactionPayloadGenerator {
  static const int targetBytes = 5 * 1024 * 1024;

  /// Generate a mock transaction payload large enough to make isolate parsing meaningful.
  static String generateLargeJson({int targetSizeBytes = targetBytes}) {
    final random = Random(42);
    final transactions = <Map<String, Object>>[];
    var encoded = '[]';
    var index = 0;

    while (encoded.length < targetSizeBytes) {
      final amount = index % 11 == 0
          ? -1 * (random.nextInt(3000) + 1)
          : random.nextInt(250000) / 100;
      transactions.add({
        'id': 'TX-${index.toString().padLeft(6, '0')}',
        'amount': amount,
        'status': index % 3 == 0 ? 'pending' : 'completed',
        'recipient': 'Customer ${index % 250}',
        'createdAt': DateTime.utc(
          2026,
          5,
          1,
        ).add(Duration(minutes: index)).toIso8601String(),
        'memo': 'Deterministic transaction payload row $index',
      });

      if (index % 500 == 0) {
        encoded = jsonEncode(transactions);
      }
      index++;
    }

    return jsonEncode(transactions);
  }
}

/// A service designed to handle heavy data processing on a background thread.
class TransactionParser {
  static Future<List<ParsedTransaction>> parseLargeJsonBackground(
    String rawJson, {
    int visibleLimit = 8,
  }) async {
    return Isolate.run(() => _parseJsonLogic(rawJson, visibleLimit));
  }

  static List<ParsedTransaction> _parseJsonLogic(
    String rawJson,
    int visibleLimit,
  ) {
    final decodedList = jsonDecode(rawJson) as List<dynamic>;

    return decodedList
        .map((e) => ParsedTransaction.fromJson(e as Map<String, dynamic>))
        .where((transaction) => transaction.amount > 0)
        .take(visibleLimit)
        .toList(growable: false);
  }
}
