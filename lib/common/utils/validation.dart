import 'package:mxc_logic/mxc_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Validation {
  static String? notEmpty(BuildContext context, String? value,
      [String? errorText]) {
    if (value?.trim().isEmpty ?? true) {
      return FlutterI18n.translate(context, errorText ?? 'reg_required');
    }

    return null;
  }

  static String? checkName(BuildContext context, String? value) {
    if (value!.length < 3 || value.length > 30) {
      return FlutterI18n.translate(context, 'domain_limit');
    }

    if (!RegExp(r'^[ZA-ZZa-z0-9]+$').hasMatch(value)) {
      return FlutterI18n.translate(context, 'domain_invalid');
    }

    return null;
  }

  static String? checkUrl(BuildContext context, String? value,
      {String? errorText}) {
    RegExp urlExp = RegExp(
        r"^((ftp|telnet|http(?:s)?):\/\/)?((www\.)?([a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))(:\d+)?(\/[^\s]*)?$");
    if (!urlExp.hasMatch(value!)) {
      return FlutterI18n.translate(context, errorText ?? 'invalid_format');
    }

    return null;
  }

  static String? checkHttps(BuildContext context, String? value,
      {String? errorText}) {
    RegExp urlExp = RegExp(r'^https://');
    if (!urlExp.hasMatch(value!)) {
      return FlutterI18n.translate(context, errorText ?? 'invalid_format');
    }

    return null;
  }

  static String? checkEthereumAddress(BuildContext context, String value) {
    try {
      EthereumAddress.fromHex(value);
      return null;
    } catch (e) {
      return FlutterI18n.translate(context, 'invalid_format');
    }
  }

  static String? checkEthereumPrivateKey(BuildContext context, String value) {
    if (!isPrivateKey(value)) {
      return FlutterI18n.translate(context, 'invalid_format');
    }
    return null;
  }

  static String? checkMnsValidation(BuildContext context, String value) {
    if (!((value.endsWith('.mxc') || value.endsWith('.MXC')) &&
        value.length > 4)) {
      return FlutterI18n.translate(context, 'invalid_format');
    }

    return null;
  }

  static String? checkNumeric(BuildContext context, String str,
      {String? errorText}) {
    String translate(String text) => FlutterI18n.translate(context, text);
    const pattern = r'^-?[0-9]+$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(str)) {
      return errorText ?? translate('invalid_format');
    } else {
      return null;
    }
  }

  static String? checkHexDecimal(BuildContext context, String value,
      {String? errorText}) {
    String translate(String text) => FlutterI18n.translate(context, text);
    final regExp = RegExp(r'0[xX][0-9a-fA-F]+');
    if (!regExp.hasMatch(value)) {
      return errorText ?? translate('invalid_format');
    } else {
      return null;
    }
  }

  static bool isExpoNumber(String input) {
    RegExp regex = RegExp(r'^(\d+\.\d+e[-+]\d+)$');
    return regex.hasMatch(input);
  }

  static bool isDecimalsStandard(String input) {
    // since It is not number
    if (!isDouble(input)) return false;

    final splitValue = input.split('.');
    final decimalPlaces = splitValue[1];

    if (decimalPlaces.length > Config.decimalWriteFixed) {
      return false;
    } else {
      return true;
    }
  }

  static bool isDouble(String value) {
    final doubleValue = double.tryParse(value);

    if (doubleValue == null) {
      return false;
    }
    return true;
  }

  static bool isAccountFormat(String value) {
    RegExp regex = RegExp(r"Account \d+");

    return regex.hasMatch(value);
  }

  static bool isAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isPrivateKey(String hex) {
    try {
      // Valid curve for private key according to here : https://ethereum.stackexchange.com/a/2320/122729
      const privateKeyLength = 64;
      final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
      hex = MXCFormatter.removeZeroX(hex);

      // Check if the hex string has valid length and is hexadecimal
      if (hex.length != privateKeyLength || !hexRegExp.hasMatch(hex)) {
        return false;
      }

      final curveOrder = BigInt.parse(
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
        radix: 16,
      );

      // Convert hex to BigInt
      final privateKey = BigInt.parse(hex, radix: 16);

      // Check if privateKey is not zero and is less than curve order
      if (privateKey == BigInt.zero || privateKey >= curveOrder) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static String? checkEmailAddress(BuildContext context, String value) {
    String pattern =
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return FlutterI18n.translate(context, 'invalid_email');
    }
    return null;
  }
}
