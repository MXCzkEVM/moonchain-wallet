import 'package:flutter/material.dart';

class CubeBarPainter extends CustomPainter {
  CubeBarPainter({
    required this.contentColor,
    required this.shadowColor,
  });

  final Color contentColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    Rect contentRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
    Paint contentPaint = Paint()..color = contentColor;

    canvas.drawRect(contentRect, contentPaint);

    Paint shadowPaint = Paint()..color = shadowColor;
    Path leftShadowPath = Path()
      ..moveTo(-8, 8)
      ..lineTo(-8, 8)
      ..lineTo(-8, 42)
      ..lineTo(0, 32)
      ..lineTo(0, 0)
      ..close();

    Path bottomShadowPath = Path()
      ..moveTo(-8, 42)
      ..lineTo(-8, 42)
      ..lineTo(0, 42)
      ..lineTo(size.width - 8, 42)
      ..lineTo(size.width, 32)
      ..lineTo(0, 32)
      ..close();

    canvas.drawPath(leftShadowPath, shadowPaint);
    canvas.drawPath(bottomShadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
