import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/security/privacy_overlay.dart';
import 'core/theme/app_theme.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: TupayApp()));
}

class TupayApp extends ConsumerWidget {
  const TupayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRestoringTransaction = ref.watch(
      transactionProvider.select((state) => state.isLoading && !state.hasValue),
    );

    if (isRestoringTransaction) {
      return MaterialApp(
        title: 'Tupay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        restorationScopeId: 'tupay_app',
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tupay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      restorationScopeId: 'tupay_app',
      // The PrivacyOverlay wrapper is to handle background blurring
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return PrivacyOverlay(child: child);
      },
    );
  }
}
