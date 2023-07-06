import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Validation {
  static String? notEmpty(BuildContext context, String? value) {
    if (value?.trim().isEmpty ?? true) {
      return FlutterI18n.translate(context, 'reg_required');
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
}
