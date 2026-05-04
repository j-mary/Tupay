import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction.dart';
import 'dashboard_state.dart';

/// A Notifier to manage the state of the Dashboard.
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardInitial();
  }

  /// Simulates fetching dashboard data from a remote source or local database.
  Future<void> fetchDashboardData() async {
    // Transition to loading state
    state = const DashboardLoading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock fetched data
      final mockTransactions = [
        Transaction(
          id: '1',
          title: 'Grocery Store',
          amount: 45.99,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          isCredit: false,
        ),
        Transaction(
          id: '2',
          title: 'Salary Deposit',
          amount: 3200.00,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isCredit: true,
        ),
        Transaction(
          id: '3',
          title: 'Coffee Shop',
          amount: 4.50,
          date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          isCredit: false,
        ),
      ];

      // Transition to loaded state
      state = DashboardLoaded(
        totalBalance: 12543.21,
        recentTransactions: mockTransactions,
      );
    } catch (e) {
      // Transition to error state if something goes wrong
      state = DashboardError(e.toString());
    }
  }
}

/// Global provider for the DashboardNotifier.
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
