import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/dashboard/domain/models/transaction.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:tupay_app/features/dashboard/presentation/screens/dashboard_screen.dart';
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

  testWidgets('Dashboard Screen Golden Test', (WidgetTester tester) async {
    final mockTransactions = [
      Transaction(
        id: '1',
        title: 'Mock Transaction',
        amount: 100.0,
        date: DateTime(2026, 5, 4),
        isCredit: true,
      ),
    ];

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith(
              () => MockDashboardNotifier(
                DashboardLoaded(
                  totalBalance: 5000.0,
                  recentTransactions: mockTransactions,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
    });

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('\$5000.00', skipOffstage: false), findsOneWidget);
    expect(find.text('Mock Transaction', skipOffstage: false), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/dashboard_screen.png'),
    );
  });
}

class MockDashboardNotifier extends DashboardNotifier {
  final DashboardState mockState;
  MockDashboardNotifier(this.mockState);

  @override
  DashboardState build() => mockState;

  @override
  Future<void> fetchDashboardData() async {}
}
