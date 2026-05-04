import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tupay_app/core/navigation/app_router.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('router starts at restored review route', () async {
    final transaction = Transaction(
      amount: 150,
      currency: Currency.usd,
      recipient: const Recipient(
        fullName: 'John Doe',
        accountNumber: '1234567890',
      ),
      paymentMethod: 'Apple Pay',
    );
    FlutterSecureStorage.setMockInitialValues({
      'transaction_state': jsonEncode(
        TransactionReviewing(transaction).toJson(),
      ),
      'transaction_route': transferReviewRoute,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(transactionProvider.future);
    final router = container.read(routerProvider);

    expect(router.routeInformationProvider.value.uri.path, transferReviewRoute);
  });

  test('router starts at restored payment route', () async {
    final transaction = Transaction(
      amount: 150,
      currency: Currency.usd,
      recipient: const Recipient(
        fullName: 'John Doe',
        accountNumber: '1234567890',
      ),
    );
    FlutterSecureStorage.setMockInitialValues({
      'transaction_state': jsonEncode(
        TransactionSelectingPaymentMethod(transaction).toJson(),
      ),
      'transaction_route': transferPaymentRoute,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(transactionProvider.future);
    final router = container.read(routerProvider);

    expect(
      router.routeInformationProvider.value.uri.path,
      transferPaymentRoute,
    );
  });
}
