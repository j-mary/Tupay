import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/security/privacy_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PrivacyOverlay obscures content when app is paused', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyOverlay(
          child: Scaffold(
            body: Center(child: Text('Sensitive Content')),
          ),
        ),
      ),
    );

    expect(find.text('Sensitive Content'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(find.byType(BackdropFilter), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.byType(BackdropFilter), findsNothing);
  });
}
