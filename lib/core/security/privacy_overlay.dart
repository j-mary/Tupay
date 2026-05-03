import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that wraps the application and applies a blur effect
/// when the app moves into the background, ensuring sensitive fintech
/// data is not visible in the OS app switcher.
class PrivacyOverlay extends StatefulWidget {
  final Widget child;

  const PrivacyOverlay({super.key, required this.child});

  @override
  State<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends State<PrivacyOverlay>
    with WidgetsBindingObserver {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (!_isObscured) {
        setState(() {
          _isObscured = true;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isObscured) {
        setState(() {
          _isObscured = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isObscured)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}
