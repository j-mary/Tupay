import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/transactions/domain/entities/transaction.dart';
import 'package:tupay_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:tupay_app/features/transactions/presentation/screens/transfer_config_screen.dart';
import 'package:tupay_app/main.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('recipient amount updates while typing send amount', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TransferConfigScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_amountField(), '100');
    await tester.pumpAndSettle();

    expect(find.text('85.00'), findsOneWidget);
  });

  testWidgets('currency selectors update conversion state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TransferConfigScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_amountField(), '100');
    await tester.pump();
    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GBP').last);
    await tester.pumpAndSettle();

    expect(find.text('114.86'), findsOneWidget);
  });

  testWidgets('close exits transfer flow from config screen', (
    WidgetTester tester,
  ) async {
    final transaction = Transaction(
      amount: 100,
      currency: Currency.usd,
      recipient: const Recipient.empty(),
    );
    FlutterSecureStorage.setMockInitialValues({
      'transaction_state': jsonEncode(
        TransactionConfiguring(transaction).toJson(),
      ),
      'transaction_route': transferConfigRoute,
    });

    await tester.pumpWidget(const ProviderScope(child: TupayApp()));
    await tester.pumpAndSettle();

    expect(find.byType(TransferConfigScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Tupay'), findsOneWidget);
  });
}

Finder _amountField() {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == '0.00',
  );
}
