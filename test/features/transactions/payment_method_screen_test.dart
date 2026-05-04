import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/screens/payment_method_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('close exits payment method screen immediately', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/transfer/payment',
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(
          path: '/transfer',
          name: 'transfer_config',
          builder: (context, state) => const Scaffold(body: Text('Config')),
          routes: [
            GoRoute(
              path: 'payment',
              name: 'payment_method',
              builder: (context, state) => const PaymentMethodScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionProvider.overrideWith(
            () => MockTransactionNotifier(
              TransactionSelectingPaymentMethod(
                Transaction(
                  amount: 100,
                  currency: Currency.usd,
                  recipient: const Recipient(
                    fullName: 'John Doe',
                    accountNumber: '1234567890',
                  ),
                ),
              ),
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(PaymentMethodScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}

class MockTransactionNotifier extends TransactionNotifier {
  final TransactionState mockState;

  MockTransactionNotifier(this.mockState);

  @override
  Future<TransactionState> build() async => mockState;

  @override
  void reset() {}
}
