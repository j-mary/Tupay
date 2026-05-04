import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/app_theme.dart';
import 'package:tupay_app/features/dashboard/domain/models/transaction.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:tupay_app/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:tupay_app/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Dashboard Screen Golden Test', (WidgetTester tester) async {
    final mockTransactions = [
      DashboardTransaction(
        id: '1',
        title: 'Mock Transaction',
        amount: 100.0,
        date: DateTime(2026, 5, 4),
        isCredit: true,
        category: TransactionCategory.funding,
        status: TransactionStatus.success,
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
                  totalProcessedTransactions: 1,
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

    expect(find.text('Tupay'), findsOneWidget);
    expect(find.text('₦5,000.00', skipOffstage: false), findsOneWidget);
    expect(find.text('1', skipOffstage: false), findsWidgets);
    expect(find.text('Mock Transaction', skipOffstage: false), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/dashboard_screen.png'),
    );
  });

  testWidgets('dashboard balance toggle hides all amounts', (
    WidgetTester tester,
  ) async {
    final mockTransactions = [
      DashboardTransaction(
        id: '1',
        title: 'Mock Transaction',
        amount: 100.0,
        date: DateTime(2026, 5, 4),
        isCredit: true,
        category: TransactionCategory.funding,
        status: TransactionStatus.success,
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
                totalProcessedTransactions: 1,
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
    expect(find.text('₦5,000.00', skipOffstage: false), findsOneWidget);
    expect(find.text('₦1,850,000.00', skipOffstage: false), findsOneWidget);
    expect(find.text('1', skipOffstage: false), findsWidgets);

    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pumpAndSettle();

    expect(find.text('••••', skipOffstage: false), findsWidgets);
    expect(find.text('₦5,000.00', skipOffstage: false), findsNothing);
    expect(find.text('₦1,850,000.00', skipOffstage: false), findsNothing);
  });

  testWidgets('scroll to top button appears after scrolling down', (
    WidgetTester tester,
  ) async {
    final mockTransactions = List.generate(
      20,
      (index) => DashboardTransaction(
        id: '$index',
        title: 'Mock Transaction $index',
        amount: 100.0 + index,
        date: DateTime(2026, 5, 4).add(Duration(minutes: index)),
        isCredit: index.isEven,
        category: TransactionCategory.funding,
        status: TransactionStatus.success,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith(
            () => MockDashboardNotifier(
              DashboardLoaded(
                totalBalance: 5000.0,
                recentTransactions: mockTransactions,
                totalProcessedTransactions: mockTransactions.length,
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
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    expect(find.text('Tupay'), findsOneWidget);
  });
}

class MockDashboardNotifier extends DashboardNotifier {
  final DashboardState mockState;
  MockDashboardNotifier(this.mockState);

  @override
  Future<DashboardState> build() async => mockState;

  @override
  Future<void> fetchDashboardData() async {}
}
