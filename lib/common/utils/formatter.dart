import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

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

  static String intThousandsSeparator(String inputString) {
    return intl.NumberFormat('#,##0').format(int.parse(inputString));
  }

  static String formatWalletAddress(String inputString) {
    if (!RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false)
        .hasMatch(inputString)) return inputString;

    if (inputString.isEmpty) return inputString;

    String formattedString =
        '${inputString.substring(0, 4)}...${inputString.substring(inputString.length - 4)}';
    return formattedString;
  }

  static String convertWeiToEth(String inputString) {
    // 10^18 = 1000000000000000000 but we want to have up to 2 digits accuracy
    if (double.parse(inputString).toDouble() < 10000000000000000) {
      return '0';
    }
    String convertedString =
        (double.parse(inputString).toDouble() / pow(10, 18)).toStringAsFixed(1);
    return convertedString;
  }

  /// The input is in wei the output is in Eth
  static String formatNumberForUI(String input, {bool isWei = true}) {
    if (isWei) {
      input = convertWeiToEth(input);
    }
    String fractionalPart = "";
    String integerPart = input;
    if (input.contains('.')) {
      integerPart = input.split('.')[0];
      fractionalPart = ".${input.split('.')[1].substring(0, 1)}";
    }
    integerPart = intThousandsSeparator(integerPart);
    return '$integerPart$fractionalPart';
  }
}
