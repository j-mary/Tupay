import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service to handle secure storage operations using `flutter_secure_storage`.
/// Used to store sensitive data like Transaction IDs.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Private constructor for dependency injection
  SecureStorageService(this._storage);

  static const String _transactionIdKey = 'transaction_id';

  /// Saves a user's transaction ID securely.
  Future<void> saveTransactionId(String transactionId) async {
    await _storage.write(key: _transactionIdKey, value: transactionId);
  }

  /// Retrieves the saved transaction ID securely.
  Future<String?> getTransactionId() async {
    return await _storage.read(key: _transactionIdKey);
  }

  /// Clears the saved transaction ID.
  Future<void> clearTransactionId() async {
    await _storage.delete(key: _transactionIdKey);
  }
}
