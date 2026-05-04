import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';

void main() {
  const storageStateKey = 'transaction_state';
  const storageRouteKey = 'transaction_route';

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('serializes and restores config step with exact route', () async {
    final transaction = _transaction();
    final savedState = TransactionConfiguring(transaction).toJson();
    FlutterSecureStorage.setMockInitialValues({
      storageStateKey: jsonEncode(savedState),
      storageRouteKey: transferConfigRoute,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final restored = await container.read(transactionProvider.future);

    expect(restored, isA<TransactionConfiguring>());
    expect(restored.routePath, transferConfigRoute);
    expect(restored.transaction.amount, 150);
  });

  test('serializes and restores payment step with exact route', () async {
    final transaction = _transaction(paymentMethod: 'Apple Pay');
    final savedState = TransactionSelectingPaymentMethod(transaction).toJson();
    FlutterSecureStorage.setMockInitialValues({
      storageStateKey: jsonEncode(savedState),
      storageRouteKey: transferPaymentRoute,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final restored = await container.read(transactionProvider.future);

    expect(restored, isA<TransactionSelectingPaymentMethod>());
    expect(restored.routePath, transferPaymentRoute);
    expect(restored.transaction.paymentMethod, 'Apple Pay');
  });

  test('serializes and restores review step with exact route', () async {
    final transaction = _transaction(paymentMethod: 'Debit / Credit Card');
    final savedState = TransactionReviewing(transaction).toJson();
    FlutterSecureStorage.setMockInitialValues({
      storageStateKey: jsonEncode(savedState),
      storageRouteKey: transferReviewRoute,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final restored = await container.read(transactionProvider.future);

    expect(restored, isA<TransactionReviewing>());
    expect(restored.routePath, transferReviewRoute);
    expect(restored.transaction.recipient.fullName, 'John Doe');
  });

  test('back transitions update state routes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(transactionProvider.future);
    final notifier = container.read(transactionProvider.notifier);

    notifier.updateAmount(120);
    notifier.updateRecipient(
      const Recipient(fullName: 'John Doe', accountNumber: '1234567890'),
    );
    expect(notifier.proceedToPaymentMethod(), isTrue);
    notifier.selectPaymentMethod('Apple Pay');

    expect(
      container.read(transactionProvider).requireValue.routePath,
      transferReviewRoute,
    );

    notifier.backToPaymentMethod();
    expect(
      container.read(transactionProvider).requireValue,
      isA<TransactionSelectingPaymentMethod>(),
    );
    expect(
      container.read(transactionProvider).requireValue.routePath,
      transferPaymentRoute,
    );

    notifier.backToConfig();
    expect(
      container.read(transactionProvider).requireValue,
      isA<TransactionConfiguring>(),
    );
    expect(
      container.read(transactionProvider).requireValue.routePath,
      transferConfigRoute,
    );
  });

  test('invalid config blocks forward navigation', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(transactionProvider.future);
    final notifier = container.read(transactionProvider.notifier);

    notifier.beginTransfer();
    final canProceed = notifier.proceedToPaymentMethod();

    expect(canProceed, isFalse);
    final state = container.read(transactionProvider).requireValue;
    expect(state, isA<TransactionError>());
    expect(state.routePath, transferConfigRoute);
  });
}

Transaction _transaction({String? paymentMethod}) {
  return Transaction(
    amount: 150,
    currency: Currency.usd,
    recipient: const Recipient(
      fullName: 'John Doe',
      accountNumber: '1234567890',
      bankName: 'Chase Bank',
    ),
    paymentMethod: paymentMethod,
  );
}
