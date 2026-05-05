import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tupay_app/core/theme/responsive_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpWithSize(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('ResponsiveLayout renders mobile child below tablet breakpoint', (
    WidgetTester tester,
  ) async {
    await pumpWithSize(
      tester,
      const Size(400, 800),
      const ResponsiveLayout(
        mobile: Text('mobile'),
        tablet: Text('tablet'),
        desktop: Text('desktop'),
      ),
    );

    expect(find.text('mobile'), findsOneWidget);
    expect(find.text('tablet'), findsNothing);
    expect(find.text('desktop'), findsNothing);
  });

  testWidgets('ResponsiveLayout renders tablet child at tablet width', (
    WidgetTester tester,
  ) async {
    await pumpWithSize(
      tester,
      const Size(800, 800),
      const ResponsiveLayout(
        mobile: Text('mobile'),
        tablet: Text('tablet'),
        desktop: Text('desktop'),
      ),
    );

    expect(find.text('tablet'), findsOneWidget);
    expect(find.text('mobile'), findsNothing);
    expect(find.text('desktop'), findsNothing);
  });

  testWidgets('ResponsiveLayout falls back to tablet when desktop is absent', (
    WidgetTester tester,
  ) async {
    await pumpWithSize(
      tester,
      const Size(1200, 800),
      const ResponsiveLayout(
        mobile: Text('mobile'),
        tablet: Text('tablet'),
      ),
    );

    expect(find.text('tablet'), findsOneWidget);
    expect(find.text('mobile'), findsNothing);
  });
}
