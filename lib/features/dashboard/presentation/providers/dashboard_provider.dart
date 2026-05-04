import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/isolate/transaction_parser.dart';
import '../../domain/models/transaction.dart';
import 'dashboard_state.dart';

/// AsyncNotifier makes dashboard loading/error explicit while DashboardState
/// preserves the UI contract used by the screen.
class DashboardNotifier extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    return const DashboardInitial();
  }

  Future<void> fetchDashboardData() async {
    state = const AsyncData(DashboardLoading());

    try {
      final mockJson = MockTransactionPayloadGenerator.generateLargeJson();
      final parsedTransactions =
          await TransactionParser.parseLargeJsonBackground(mockJson);

      final today = DateTime(2026, 5, 4);
      final recentTransactions = parsedTransactions
          .map((parsed) {
            return Transaction(
              id: parsed.id,
              title: 'Transaction ${parsed.id}',
              amount: parsed.amount,
              date: today,
              isCredit: parsed.status == 'completed',
            );
          })
          .toList(growable: false);

      await Future<void>.delayed(const Duration(milliseconds: 350));

      state = AsyncData(
        DashboardLoaded(
          totalBalance: 12543.21,
          recentTransactions: recentTransactions,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(DashboardError(error.toString()));
    }
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );
