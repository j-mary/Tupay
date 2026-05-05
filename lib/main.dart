import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/security/privacy_overlay.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/responsive_layout.dart';
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

    return isRestoringTransaction
        ? MaterialApp(
            title: 'Tupay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            scrollBehavior: const AppScrollBehavior(),
            restorationScopeId: 'tupay_app',
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            builder: _buildAppShell,
          )
        : MaterialApp.router(
            title: 'Tupay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            scrollBehavior: const AppScrollBehavior(),
            routerConfig: ref.watch(routerProvider),
            restorationScopeId: 'tupay_app',
            builder: _buildAppShell,
          );
  }

  Widget _buildAppShell(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();

    return PrivacyOverlay(
      child: ResponsiveLayout(
        mobile: child,
        tablet: Center(
          // Constrain tablet width so the UI stays centered
          // instead of stretching edge to edge.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
        desktop: Center(
          // Constrain desktop width so the UI stays centered
          // instead of stretching edge to edge.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: child,
          ),
        ),
      ),
    );
  }
}
