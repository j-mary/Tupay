import '../../domain/models/transaction.dart';

/// Represents the UI state of the Dashboard.
sealed class DashboardState {
  const DashboardState();
}

/// Represents the initial state before any fetch operation.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Represents that a fetch operation is currently in progress.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Represents a successfully completed fetch operation.
class DashboardLoaded extends DashboardState {
  final double totalBalance;
  final List<DashboardTransaction> recentTransactions;
  final int totalProcessedTransactions;

  const DashboardLoaded({
    required this.totalBalance,
    required this.recentTransactions,
    required this.totalProcessedTransactions,
  });
}

/// Represents an error that occurred during a fetch operation.
class DashboardError extends DashboardState {
  final String errorMessage;

  const DashboardError(this.errorMessage);
}
