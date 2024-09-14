import 'package:flutter/material.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';

extension LanguageExt on Language {
  Locale toLocale() {
    final sourceCode = code.split('_');
    final languageCode = sourceCode[0];
    final countryCode = sourceCode.length >= 2 ? sourceCode[1] : null;
    return Locale(languageCode, countryCode);
  }
}
