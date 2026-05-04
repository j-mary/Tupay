import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('restored review state renders review screen content', (
    tester,
  ) async {
    final transaction = Transaction(
      amount: 200,
      currency: Currency.usd,
      recipient: const Recipient(
        fullName: 'Ada Rivers',
        accountNumber: '9876543210',
      ),
      paymentMethod: 'Apple Pay',
    );

    FlutterSecureStorage.setMockInitialValues({
      'transaction_state': jsonEncode(
        TransactionReviewing(transaction).toJson(),
      ),
      'transaction_route': transferReviewRoute,
    });

    await tester.pumpWidget(const ProviderScope(child: TupayApp()));
    await tester.pumpAndSettle();

    expect(find.text('Review Transfer'), findsOneWidget);
    expect(find.text('Ada Rivers'), findsOneWidget);
    expect(find.text('Apple Pay'), findsOneWidget);
  });
}
