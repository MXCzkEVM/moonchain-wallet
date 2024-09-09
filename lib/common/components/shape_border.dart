import 'package:flutter/material.dart';

class RoundedBottomBorder extends ShapeBorder {
  final BorderSide bottomBorder;

  RoundedBottomBorder({required this.bottomBorder});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: bottomBorder.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      ));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // Deflate the rectangle by the border width to draw the border from the inside
    final deflatedRect = rect.deflate(bottomBorder.width / 2);
    final rrect = RRect.fromRectAndRadius(
      deflatedRect,
      const Radius.circular(8),
    );

    // final paint = Paint()
    //   ..color = bottomBorder.color
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = bottomBorder.width + 4;

    // final path = Path()
    //   ..moveTo(deflatedRect.left, deflatedRect.bottom - 4)
    //   ..lineTo(deflatedRect.right, deflatedRect.bottom - 4);

    // Draw the border only on the path, which is now inside the original bounds
    // canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => RoundedBottomBorder(
        bottomBorder: bottomBorder.scale(t),
      );

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) {
    if (a is RoundedBottomBorder) {
      return RoundedBottomBorder(
        bottomBorder: BorderSide.lerp(a.bottomBorder, bottomBorder, t),
      );
    }
    return super.lerpFrom(a, t)!;
  }

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) {
    if (b is RoundedBottomBorder) {
      return RoundedBottomBorder(
        bottomBorder: BorderSide.lerp(bottomBorder, b.bottomBorder, t),
      );
    }
    return super.lerpTo(b, t)!;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        rect.deflate(bottomBorder.width),
        const Radius.circular(8),
      ));
  }
}