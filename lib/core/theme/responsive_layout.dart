import 'package:flutter/material.dart';

/// A utility widget that helps build responsive layouts based on screen width.
/// It differentiates between Mobile (e.g. iPhone SE) and Tablet (e.g. Android Tablet) devices.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  // Typical breakpoint for tablet is around 600 logical pixels.
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  /// Helper to determine if the current device is considered Mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  /// Helper to determine if the current device is considered Tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint &&
      MediaQuery.sizeOf(context).width < desktopBreakpoint;

  /// Helper to determine if the current device is considered Desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return desktop ?? tablet;
        } else if (constraints.maxWidth >= tabletBreakpoint) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
