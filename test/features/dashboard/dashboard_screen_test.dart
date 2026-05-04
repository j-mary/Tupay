import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/dashboard/domain/models/transaction.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:tupay_app/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard Screen Golden Test', (WidgetTester tester) async {
    // Provide a mocked state to the dashboard provider
    final mockTransactions = [
      Transaction(
        id: '1',
        title: 'Mock Transaction',
        amount: 100.0,
        date: DateTime(2026, 5, 4),
        isCredit: true,
      ),
    ];

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

    // Wait for everything to settle
    await tester.pumpAndSettle();

    // Verify UI elements exist
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('\$5000.00'), findsOneWidget);
    expect(find.text('Mock Transaction'), findsOneWidget);
  });
}

class MockDashboardNotifier extends DashboardNotifier {
  final DashboardState mockState;
  MockDashboardNotifier(this.mockState);

  @override
  DashboardState build() => mockState;

  @override
  Future<void> fetchDashboardData() async {
    // Do nothing for mock
  }
}
