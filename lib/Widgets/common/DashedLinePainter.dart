import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Horizontal dashed separator rendered with a custom painter.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = const Color(0xFFEEEEEE),
    this.dashWidth = 4.0,
    this.gap = 3.0,
    this.thickness = 1.0,
  });

  final Color color;
  final double dashWidth;
  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, thickness),
      painter: DashedLinePainter(
        color: color,
        dashWidth: dashWidth,
        gap: gap,
        thickness: thickness,
      ),
    );
  }
}

/// Paints evenly spaced horizontal dashes across the available width.
class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.gap,
    required this.thickness,
  });

  final Color color;
  final double dashWidth;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    final y = size.height / 2;
    var startX = 0.0;
    while (startX < size.width) {
      final endX = math.min(startX + dashWidth, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.thickness != thickness;
  }
}
