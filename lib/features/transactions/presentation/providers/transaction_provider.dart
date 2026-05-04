import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/security/secure_storage_service.dart';
import '../../domain/entities/transaction.dart';

const dashboardRoute = '/';
const transferConfigRoute = '/transfer';
const transferPaymentRoute = '/transfer/payment';
const transferReviewRoute = '/transfer/review';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

/// Sealed class representing the visible states of the transaction flow.
sealed class TransactionState {
  final Transaction transaction;
  final String routePath;

  const TransactionState(this.transaction, {required this.routePath});

  bool get hasActiveDraft => routePath != dashboardRoute;

  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'routePath': routePath,
      'transaction': transaction.toJson(),
    };
  }

  static TransactionState initial() {
    return TransactionConfiguring(
      _emptyTransaction(),
      routePath: dashboardRoute,
    );
  }

  static TransactionState? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final type = json['type'];
    final txJson = json['transaction'];
    if (txJson == null) return null;
    final transaction = Transaction.fromJson(Map<String, dynamic>.from(txJson));
    final routePath = json['routePath'] as String?;

    switch (type) {
      case 'TransactionConfiguring':
        return TransactionConfiguring(
          transaction,
          routePath: routePath ?? transferConfigRoute,
        );
      case 'TransactionSelectingPaymentMethod':
        return TransactionSelectingPaymentMethod(
          transaction,
          routePath: routePath ?? transferPaymentRoute,
        );
      case 'TransactionReviewing':
        return TransactionReviewing(
          transaction,
          routePath: routePath ?? transferReviewRoute,
        );
      case 'TransactionProcessing':
        return TransactionProcessing(
          transaction,
          routePath: routePath ?? transferReviewRoute,
        );
      case 'TransactionSuccess':
        return TransactionSuccess(
          transaction,
          routePath: routePath ?? transferReviewRoute,
        );
      case 'TransactionError':
        final message = json['message'] as String? ?? 'Unknown error';
        return TransactionError(
          transaction,
          message,
          routePath: routePath ?? transferConfigRoute,
        );
      default:
        return null;
    }
  }

  static String routeFor(TransactionState state) => state.routePath;

  static Transaction _emptyTransaction() {
    return Transaction(
      amount: 0.0,
      currency: Currency.ngn,
      recipient: const Recipient.empty(),
    );
  }
}

/// Initial state where the user configures the amount and recipient.
class TransactionConfiguring extends TransactionState {
  const TransactionConfiguring(
    super.transaction, {
    super.routePath = transferConfigRoute,
  });
}

/// State where the user selects a payment method.
class TransactionSelectingPaymentMethod extends TransactionState {
  const TransactionSelectingPaymentMethod(
    super.transaction, {
    super.routePath = transferPaymentRoute,
  });
}

/// State where the user reviews the transaction details.
class TransactionReviewing extends TransactionState {
  const TransactionReviewing(
    super.transaction, {
    super.routePath = transferReviewRoute,
  });
}

/// State while the transaction is being processed.
class TransactionProcessing extends TransactionState {
  const TransactionProcessing(
    super.transaction, {
    super.routePath = transferReviewRoute,
  });
}

/// State when the transaction has been completed successfully.
class TransactionSuccess extends TransactionState {
  const TransactionSuccess(
    super.transaction, {
    super.routePath = transferReviewRoute,
  });
}

/// State when the transaction fails.
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(
    super.transaction,
    this.message, {
    required super.routePath,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['message'] = message;
    return data;
  }
}

/// AsyncNotifier keeps restoration/loading explicit while the sealed
/// TransactionState continues to model the user-visible flow.
class TransactionNotifier extends AsyncNotifier<TransactionState> {
  late SecureStorageService _secureStorage;

  @override
  Future<TransactionState> build() async {
    _secureStorage = ref.watch(secureStorageServiceProvider);
    return _loadState();
  }

  TransactionState get currentState =>
      state.asData?.value ?? TransactionState.initial();

  Future<TransactionState> _loadState() async {
    try {
      final stateStr = await _secureStorage.getTransactionState();
      if (stateStr == null) return TransactionState.initial();

      final decoded = jsonDecode(stateStr);
      final restoredState = TransactionState.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
      if (restoredState == null) return TransactionState.initial();

      final savedRoute = await _secureStorage.getTransactionRoute();
      if (savedRoute == null || savedRoute == restoredState.routePath) {
        return restoredState;
      }

      return _copyWithRoute(restoredState, savedRoute);
    } catch (_) {
      return TransactionState.initial();
    }
  }

  void _setTransactionState(TransactionState next, {bool persist = true}) {
    state = AsyncData(next);
    if (persist) {
      _persistState(next);
    }
  }

  Future<void> _persistState(TransactionState currentState) async {
    try {
      // The route is stored next to the secure draft so process death restores
      // the exact step instead of inferring from an incomplete transaction.
      final jsonStr = jsonEncode(currentState.toJson());
      await _secureStorage.saveTransactionState(jsonStr);
      await _secureStorage.saveTransactionRoute(currentState.routePath);
    } catch (_) {
      // Saving transfer progress is best effort.
    }
  }

  void beginTransfer() {
    final current = currentState;
    final next = TransactionConfiguring(
      current.transaction,
      routePath: transferConfigRoute,
    );
    _setTransactionState(next);
  }

  void updateAmount(double amount) {
    _setTransactionState(
      TransactionConfiguring(currentState.transaction.copyWith(amount: amount)),
    );
  }

  void updateCurrency(Currency currency) {
    _setTransactionState(
      TransactionConfiguring(
        currentState.transaction.copyWith(currency: currency),
      ),
    );
  }

  void updateRecipientCurrency(Currency currency) {
    _setTransactionState(
      TransactionConfiguring(
        currentState.transaction.copyWith(recipientCurrency: currency),
      ),
    );
  }

  void updateRecipient(Recipient recipient) {
    _setTransactionState(
      TransactionConfiguring(
        currentState.transaction.copyWith(recipient: recipient),
      ),
    );
  }

  bool validateConfig() {
    final t = currentState.transaction;
    if (t.amount <= 0) {
      _setTransactionState(
        TransactionError(
          t,
          'Amount must be greater than zero',
          routePath: transferConfigRoute,
        ),
      );
      return false;
    }
    if (t.recipient.fullName.isEmpty || t.recipient.accountNumber.isEmpty) {
      _setTransactionState(
        TransactionError(
          t,
          'Recipient details are incomplete',
          routePath: transferConfigRoute,
        ),
      );
      return false;
    }
    return true;
  }

  /// Forward transitions only occur after validation so route and provider
  /// state remain synchronized.
  bool proceedToPaymentMethod() {
    if (!validateConfig()) return false;
    _setTransactionState(
      TransactionSelectingPaymentMethod(currentState.transaction),
    );
    return true;
  }

  void selectPaymentMethod(String method) {
    _setTransactionState(
      TransactionReviewing(
        currentState.transaction.copyWith(paymentMethod: method),
      ),
    );
  }

  void backToConfig() {
    _setTransactionState(TransactionConfiguring(currentState.transaction));
  }

  void backToPaymentMethod() {
    _setTransactionState(
      TransactionSelectingPaymentMethod(currentState.transaction),
    );
  }

  Future<void> submitTransaction() async {
    final currentTransaction = currentState.transaction;
    _setTransactionState(TransactionProcessing(currentTransaction));

    await Future<void>.delayed(const Duration(seconds: 2));

    try {
      final txId = 'TX-${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.saveTransactionId(txId);
    } catch (_) {
      // The receipt can still succeed if best-effort local ID persistence fails.
    }

    _setTransactionState(TransactionSuccess(currentTransaction));
  }

  void reset() {
    _setTransactionState(TransactionState.initial(), persist: false);
    _secureStorage.clearTransactionState();
    _secureStorage.clearTransactionRoute();
  }

  TransactionState _copyWithRoute(TransactionState source, String routePath) {
    return switch (source) {
      TransactionConfiguring(:final transaction) => TransactionConfiguring(
        transaction,
        routePath: routePath,
      ),
      TransactionSelectingPaymentMethod(:final transaction) =>
        TransactionSelectingPaymentMethod(transaction, routePath: routePath),
      TransactionReviewing(:final transaction) => TransactionReviewing(
        transaction,
        routePath: routePath,
      ),
      TransactionProcessing(:final transaction) => TransactionProcessing(
        transaction,
        routePath: routePath,
      ),
      TransactionSuccess(:final transaction) => TransactionSuccess(
        transaction,
        routePath: routePath,
      ),
      TransactionError(:final transaction, :final message) => TransactionError(
        transaction,
        message,
        routePath: routePath,
      ),
    };
  }
}

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, TransactionState>(
      TransactionNotifier.new,
    );
