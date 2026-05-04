import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/isolate/transaction_parser.dart';
import '../../domain/models/transaction.dart';
import 'dashboard_state.dart';

/// A Notifier to manage the state of the Dashboard.
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardInitial();
  }

  /// Fetches dashboard data, delegating heavy JSON parsing to a background
  /// isolate via [TransactionParser] to keep the UI thread at 120 FPS.
  Future<void> fetchDashboardData() async {
    state = const DashboardLoading();

    try {
      // Mocked payload standing in for a real 5MB network response.
      // The isolate filters transactions where amount > 0, so both items here
      // will pass — demonstrating the filter logic is active.
      final mockJson = json.encode([
        {'id': 'TX-001', 'amount': 1500.0, 'status': 'completed'},
        {'id': 'TX-002', 'amount': 250.0, 'status': 'pending'},
        {'id': 'TX-003', 'amount': 4.50, 'status': 'completed'},
      ]);

      // Runs on a separate isolate; the UI thread is never blocked.
      final parsedTransactions =
          await TransactionParser.parseLargeJsonBackground(mockJson);

      // Map typed ParsedTransaction objects to our domain Transaction entity.
      final recentTransactions = parsedTransactions.map((parsed) {
        return Transaction(
          id: parsed.id,
          title: 'Transaction ${parsed.id}',
          amount: parsed.amount,
          date: DateTime.now(),
          isCredit: parsed.status == 'completed',
        );
      }).toList();

      // Simulate network latency on top of isolate processing.
      await Future.delayed(const Duration(seconds: 1));

      state = DashboardLoaded(
        totalBalance: 12543.21,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      state = DashboardError(e.toString());
    }
  }
}

/// Global provider for the DashboardNotifier.
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  () {
    return DashboardNotifier();
  },
);
