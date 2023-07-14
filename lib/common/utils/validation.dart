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

  static String? checkUrl(BuildContext context, String? value) {
    RegExp urlExp = RegExp(
        r"(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?");
    if (!urlExp.hasMatch(value!)) {
      return FlutterI18n.translate(context, 'invalid_format');
    }

    return null;
  }

  static String? checkEthereumAddress(BuildContext context, String value) {
    if (!RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false).hasMatch(value)) {
      return FlutterI18n.translate(context, 'invalid_format');
    }

    return null;
  }
}
