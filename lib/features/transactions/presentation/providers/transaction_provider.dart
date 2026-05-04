import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tupay_app/core/security/secure_storage_service.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';

/// Sealed class representing the various states of the transaction flow.
sealed class TransactionState {
  final Transaction transaction;

  const TransactionState(this.transaction);

  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'transaction': transaction.toJson(),
    };
  }

  static TransactionState? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final type = json['type'];
    final txJson = json['transaction'];
    if (txJson == null) return null;
    final transaction = Transaction.fromJson(Map<String, dynamic>.from(txJson));

    switch (type) {
      case 'TransactionConfiguring':
        return TransactionConfiguring(transaction);
      case 'TransactionSelectingPaymentMethod':
        return TransactionSelectingPaymentMethod(transaction);
      case 'TransactionReviewing':
        return TransactionReviewing(transaction);
      case 'TransactionProcessing':
        return TransactionProcessing(transaction);
      case 'TransactionSuccess':
        return TransactionSuccess(transaction);
      case 'TransactionError':
        final message = json['message'] as String? ?? 'Unknown error';
        return TransactionError(transaction, message);
      default:
        return null;
    }
  }
}

/// Initial state where the user configures the amount and recipient.
class TransactionConfiguring extends TransactionState {
  const TransactionConfiguring(super.transaction);
}

/// State where the user selects a payment method.
class TransactionSelectingPaymentMethod extends TransactionState {
  const TransactionSelectingPaymentMethod(super.transaction);
}

/// State where the user reviews the transaction details.
class TransactionReviewing extends TransactionState {
  const TransactionReviewing(super.transaction);
}

/// State while the transaction is being processed.
class TransactionProcessing extends TransactionState {
  const TransactionProcessing(super.transaction);
}

/// State when the transaction has been completed successfully.
class TransactionSuccess extends TransactionState {
  const TransactionSuccess(super.transaction);
}

/// State when the transaction fails.
class TransactionError extends TransactionState {
  final String message;
  const TransactionError(super.transaction, this.message);

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['message'] = message;
    return data;
  }
}

/// Notifier to manage the transaction flow state.
class TransactionNotifier extends Notifier<TransactionState> {
  // The real SecureStorageService is backed by flutter_secure_storage,
  // which writes to the iOS Keychain / Android Keystore.
  final _secureStorage = SecureStorageService(const FlutterSecureStorage());

  @override
  TransactionState build() {
    // Attempt to load persisted state on init
    Future.microtask(_loadState);

    return TransactionConfiguring(
      Transaction(
        amount: 0.0,
        currency: Currency.usd,
        recipient: const Recipient.empty(),
      ),
    );
  }

  @override
  set state(TransactionState value) {
    super.state = value;
    _persistState(value);
  }

  Future<void> _loadState() async {
    try {
      final stateStr = await _secureStorage.getTransactionState();
      if (stateStr != null) {
        final json = jsonDecode(stateStr);
        final restoredState = TransactionState.fromJson(json);
        if (restoredState != null) {
          state = restoredState;
        }
      }
    } catch (_) {
      // Ignore parse errors, fallback to default
    }
  }

  Future<void> _persistState(TransactionState currentState) async {
    try {
      final jsonStr = jsonEncode(currentState.toJson());
      await _secureStorage.saveTransactionState(jsonStr);
    } catch (_) {
      // Best effort saving
    }
  }

  void updateAmount(double amount) {
    state = TransactionConfiguring(state.transaction.copyWith(amount: amount));
  }

  void updateCurrency(Currency currency) {
    state = TransactionConfiguring(state.transaction.copyWith(currency: currency));
  }

  void updateRecipient(Recipient recipient) {
    state = TransactionConfiguring(state.transaction.copyWith(recipient: recipient));
  }

  bool validateConfig() {
    final t = state.transaction;
    if (t.amount <= 0) {
      state = TransactionError(t, 'Amount must be greater than zero');
      return false;
    }
    if (t.recipient.fullName.isEmpty || t.recipient.accountNumber.isEmpty) {
      state = TransactionError(t, 'Recipient details are incomplete');
      return false;
    }
    return true;
  }

  void proceedToPaymentMethod() {
    if (validateConfig()) {
      state = TransactionSelectingPaymentMethod(state.transaction);
    }
  }

  void selectPaymentMethod(String method) {
    state = TransactionReviewing(state.transaction.copyWith(paymentMethod: method));
  }

  void backToConfig() {
    state = TransactionConfiguring(state.transaction);
  }

  void backToPaymentMethod() {
    state = TransactionSelectingPaymentMethod(state.transaction);
  }

  Future<void> submitTransaction() async {
    final currentTransaction = state.transaction;
    state = TransactionProcessing(currentTransaction);

    try {
      // Simulate network delay for a real-world feel
      await Future.delayed(const Duration(seconds: 2));
      
      // Persist transaction ID to secure platform storage
      final txId = 'TX-${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.saveTransactionId(txId);
      
      state = TransactionSuccess(currentTransaction);
    } catch (e) {
      state = TransactionError(currentTransaction, 'Network error. Please try again.');
    }
  }

  void reset() {
    state = TransactionConfiguring(
      Transaction(
        amount: 0.0,
        currency: Currency.usd,
        recipient: const Recipient.empty(),
      ),
    );
    _secureStorage.clearTransactionState();
  }
}

/// Provider for the TransactionNotifier.
final transactionProvider = NotifierProvider<TransactionNotifier, TransactionState>(() {
  return TransactionNotifier();
});
