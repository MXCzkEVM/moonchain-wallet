import 'package:flutter/material.dart';

class Formatter {
  static String formatBigNumber(double number) {
    if (number >= 1000000000) {
      // Convert to millions
      double num = number / 1000000000.0;
      return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}B';
    } else if (number >= 1000000) {
      // Convert to millions
      double num = number / 1000000.0;
      return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}M';
    } else if (number >= 1000) {
      // Convert to thousands
      double num = number / 1000.0;
      return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}K';
    } else {
      int accuracy = number.toString().split('.').last.length;
      var str = number.toString();
      if (str.endsWith('.0')) {
        return str.substring(0, str.length - 2);
      }
      return number.toStringAsFixed(accuracy);
    }
  }

  static String formatWalletAddress(String inputString) {
    String formattedString =
        '${inputString.substring(0, 6)}...${inputString.substring(inputString.length - 4)}';
    return formattedString;
  }

  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }
}
