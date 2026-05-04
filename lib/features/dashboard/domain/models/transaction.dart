enum TransactionStatus { success, pending, failed }

enum TransactionCategory { funding, transfer, cardPayment }

/// A model representing a financial transaction for the dashboard view.
class DashboardTransaction {
  final String id;
  final String title;
  final String? subtitle;
  final String? recipient;
  final double amount;
  final DateTime date;
  final bool isCredit;
  final TransactionStatus status;
  final TransactionCategory category;

  const DashboardTransaction({
    required this.id,
    required this.title,
    this.subtitle,
    this.recipient,
    required this.amount,
    required this.date,
    required this.isCredit,
    this.status = TransactionStatus.success,
    this.category = TransactionCategory.funding,
  });
}
