import 'package:flutter/material.dart';

/// A custom painter that draws a jagged "receipt" edge.
class JaggedEdgePainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final double waveHeight;
  final double waveWidth;

  const JaggedEdgePainter({
    required this.color,
    this.isTop = false,
    this.waveHeight = 8.0,
    this.waveWidth = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTop) {
      path.moveTo(0, waveHeight);
      for (double i = 0; i < size.width; i += waveWidth) {
        path.relativeLineTo(waveWidth / 2, -waveHeight);
        path.relativeLineTo(waveWidth / 2, waveHeight);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - waveHeight);
      for (double i = size.width; i > 0; i -= waveWidth) {
        path.relativeLineTo(-waveWidth / 2, waveHeight);
        path.relativeLineTo(-waveWidth / 2, -waveHeight);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant JaggedEdgePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isTop != isTop ||
        oldDelegate.waveHeight != waveHeight ||
        oldDelegate.waveWidth != waveWidth;
  }
}

/// A widget that displays a jagged edge.
class JaggedReceiptEdge extends StatelessWidget {
  final Color color;
  final bool isTop;
  final double height;
  final double waveHeight;
  final double waveWidth;

  const JaggedReceiptEdge({
    super.key,
    required this.color,
    this.isTop = false,
    this.height = 16.0,
    this.waveHeight = 8.0,
    this.waveWidth = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: CustomPaint(
        painter: JaggedEdgePainter(
          color: color,
          isTop: isTop,
          waveHeight: waveHeight,
          waveWidth: waveWidth,
        ),
      ),
    );
  }
}
