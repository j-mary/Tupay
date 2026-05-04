import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/screens/transfer_summary_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Transfer Summary Screen Golden Test', (
    WidgetTester tester,
  ) async {
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
    final router = GoRouter(
      initialLocation: '/transfer/review',
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
              builder: (context, state) =>
                  const Scaffold(body: Text('Payment')),
            ),
            GoRoute(
              path: 'review',
              name: 'transfer_review',
              builder: (context, state) => const TransferSummaryScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionProvider.overrideWith(
              () => MockTransactionNotifier(TransactionReviewing(mockTx)),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
    });

    await tester.pumpAndSettle();

    expect(find.text('Review Transfer'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('\$152.50'), findsOneWidget); // totalToPay

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/transfer_summary_screen.png'),
    );
  });

  testWidgets('shows success modal after review submit', (
    WidgetTester tester,
  ) async {
    final mockTx = Transaction(
      amount: 150.0,
      currency: Currency.usd,
      recipient: const Recipient(
        fullName: 'John Doe',
        accountNumber: '1234567890',
      ),
      paymentMethod: 'Debit Card',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionProvider.overrideWith(
            () => MockTransactionNotifier(TransactionReviewing(mockTx)),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: GoRouter(
            initialLocation: '/transfer/review',
            routes: [
              GoRoute(
                path: '/',
                name: 'dashboard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
              GoRoute(
                path: '/transfer',
                name: 'transfer_config',
                builder: (context, state) =>
                    const Scaffold(body: Text('Config')),
                routes: [
                  GoRoute(
                    path: 'payment',
                    name: 'payment_method',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Payment')),
                  ),
                  GoRoute(
                    path: 'review',
                    name: 'transfer_review',
                    builder: (context, state) => const TransferSummaryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('REVIEW & SEND'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('Transfer Successful!'), findsOneWidget);

    await tester.tap(find.text('BACK TO HOME'));
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
  Future<void> submitTransaction() async {
    final transaction = currentState.transaction;
    state = AsyncData(TransactionProcessing(transaction));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    state = AsyncData(TransactionSuccess(transaction));
  }

  @override
  void reset() {}
}
