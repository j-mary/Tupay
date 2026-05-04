import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/payment_method_screen.dart';
import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../features/transactions/presentation/screens/transfer_config_screen.dart';
import '../../features/transactions/presentation/screens/transfer_summary_screen.dart';

const dashboardRouteName = 'dashboard';
const transferConfigRouteName = 'transfer_config';
const paymentMethodRouteName = 'payment_method';
const transferReviewRouteName = 'transfer_review';

/// [GoRouter] instance.
final routerProvider = Provider<GoRouter>((ref) {
  final restoredTransaction = ref.read(transactionProvider).requireValue;

  return GoRouter(
    initialLocation: restoredTransaction.routePath,
    routes: [
      GoRoute(
        path: dashboardRoute,
        name: dashboardRouteName,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: transferConfigRoute,
        name: transferConfigRouteName,
        builder: (context, state) => const TransferConfigScreen(),
        routes: [
          GoRoute(
            path: transferPaymentRoute.path,
            name: paymentMethodRouteName,
            builder: (context, state) => const PaymentMethodScreen(),
          ),
          GoRoute(
            path: transferReviewRoute.path,
            name: transferReviewRouteName,
            builder: (context, state) => const TransferSummaryScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );
});

extension RoutePathSegment on String {
  String get path {
    if (this == dashboardRoute) return this;
    return split('/').where((segment) => segment.isNotEmpty).last;
  }
}
