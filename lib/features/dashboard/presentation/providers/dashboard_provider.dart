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

      await Future<void>.delayed(const Duration(milliseconds: 350));

      final recentTransactions = parsedTransactions
          .take(5)
          .map((parsed) {
            return DashboardTransaction(
              id: parsed.id,
              title: _titleForTransaction(parsed),
              subtitle: _subtitleForTransaction(parsed),
              recipient: parsed.recipient,
              amount: parsed.amount.abs(),
              date: parsed.createdAt,
              isCredit: parsed.amount > 0,
              status: parsed.status == 'completed'
                  ? TransactionStatus.success
                  : TransactionStatus.pending,
              category: _categoryForTransaction(parsed),
            );
          })
          .toList(growable: false);

      final totalBalance = parsedTransactions.fold<double>(0, (sum, item) {
        return sum + item.amount;
      });

      state = AsyncData(
        DashboardLoaded(
          totalBalance: totalBalance,
          recentTransactions: recentTransactions,
          totalProcessedTransactions: parsedTransactions.length,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(DashboardError(error.toString()));
    }
  }

  TransactionCategory _categoryForTransaction(ParsedTransaction parsed) {
    if (parsed.recipient == null || parsed.recipient!.isEmpty) {
      return TransactionCategory.funding;
    }
    if (parsed.status == 'pending') {
      return TransactionCategory.transfer;
    }
    return TransactionCategory.cardPayment;
  }

  String _titleForTransaction(ParsedTransaction parsed) {
    if (parsed.recipient == null || parsed.recipient!.isEmpty) {
      return 'Wallet Funding';
    }
    if (parsed.status == 'pending') {
      return 'Transfer to ${parsed.recipient}';
    }
    return parsed.recipient ?? 'Card Payment';
  }

  String? _subtitleForTransaction(ParsedTransaction parsed) {
    if (parsed.recipient == null || parsed.recipient!.isEmpty) {
      return 'Bank Transfer';
    }
    if (parsed.status == 'pending') {
      return 'External Bank';
    }
    return 'Virtual Card';
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );
