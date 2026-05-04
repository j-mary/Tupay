import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/payment_method_screen.dart';
import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../features/transactions/presentation/screens/transfer_config_screen.dart';
import '../../features/transactions/presentation/screens/transfer_summary_screen.dart';

/// [GoRouter] instance.
final routerProvider = Provider<GoRouter>((ref) {
  final restoredTransaction = ref.watch(transactionProvider).requireValue;

  return GoRouter(
    initialLocation: restoredTransaction.routePath,
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/transfer',
        name: 'transfer_config',
        builder: (context, state) => const TransferConfigScreen(),
        routes: [
          GoRoute(
            path: 'payment',
            name: 'payment_method',
            builder: (context, state) => const PaymentMethodScreen(),
          ),
          GoRoute(
            path: 'review',
            name: 'transfer_review',
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
