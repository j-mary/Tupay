import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/screens/transfer_summary_screen.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '.';
      }
      return null;
    });
  });

  testWidgets('Transfer Summary Screen Golden Test', (WidgetTester tester) async {
    // Provide a mocked state
    final mockTx = Transaction(
      amount: 150.0,
      currency: Currency.usd,
      recipient: const Recipient(
        fullName: 'John Doe',
        accountNumber: '1234567890',
        bankName: 'Chase Bank',
      ),
      paymentMethod: 'Debit Card',
      fee: 2.50,
      estimatedArrival: DateTime(2026, 5, 5),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionProvider.overrideWith(
              () => MockTransactionNotifier(TransactionReviewing(mockTx)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const TransferSummaryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
    });

    await tester.pumpAndSettle();

    expect(find.text('Review Transfer'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('152.50 USD'), findsOneWidget); // totalToPay

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/transfer_summary_screen.png'),
    );
  });
}

class MockTransactionNotifier extends TransactionNotifier {
  final TransactionState mockState;
  MockTransactionNotifier(this.mockState);

  @override
  TransactionState build() => mockState;
}
