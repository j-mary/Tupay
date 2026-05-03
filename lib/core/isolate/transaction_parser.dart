import 'dart:convert';
import 'dart:isolate';

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

/// A service designed to handle heavy data processing on a background thread.
/// This ensures the main UI thread stays at a locked 120 FPS.
class TransactionParser {
  /// Simulates parsing a 5MB JSON string array into Dart objects.
  /// Executes the parsing in a background isolate.
  static Future<List<ParsedTransaction>> parseLargeJsonBackground(String rawJson) async {
    // Isolate.run spawns a new isolate, runs the callback, returns the result, and closes the isolate.
    // This is ideal for one-off heavy computations.
    return await Isolate.run(() {
      return _parseJsonLogic(rawJson);
    });
  }

  /// The actual parsing logic that runs in the background.
  /// This is a static top-level function logic so it can be passed to the isolate.
  static List<ParsedTransaction> _parseJsonLogic(String rawJson) {
    final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;
    
    // Simulating extra CPU work to mimic a 5MB complex payload filter
    final List<ParsedTransaction> parsed = decodedList
        .map((e) => ParsedTransaction.fromJson(e as Map<String, dynamic>))
        .where((t) => t.amount > 0) // Example filter
        .toList();
        
    return parsed;
  }
}
