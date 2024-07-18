import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';

class ContextLessTranslationUseCase extends ReactiveUseCase {
  ContextLessTranslationUseCase(
    this._languageUseCase,
  ) {
    setupTranslator();
  }

  final LanguageUseCase _languageUseCase;

  bool initialized = false;
  static Map<String, dynamic>? _currentTranslations;

  Future<void> setupTranslator() async {
    if (!initialized) {
      final Locale currentLocale =
          _languageUseCase.currentLocale.value?.toLocale() ?? window.locale;
      await loadTranslations(currentLocale);
      initialized = true;
    }
  }

  Future<void> loadTranslations(Locale locale) async {
    final languageCode = locale.languageCode;
    final countyCode = locale.countryCode;
    // Read the JSON file based on the locale
    String filePath = countyCode != null
        ? 'assets/flutter_i18n/${languageCode}_$countyCode.json'
        : 'assets/flutter_i18n/$languageCode.json';
    late String jsonString;

    try {
      jsonString = await rootBundle.loadString(filePath);
    } catch (e) {
      filePath = 'assets/flutter_i18n/$languageCode.json';
      jsonString = await rootBundle.loadString(filePath);
    }

    _currentTranslations = jsonDecode(jsonString);
  }

  String translate(String key) {
    if (_currentTranslations == null) {
      throw "Translations not loaded";
    }

    // Access translation for the given key
    String? translation = _currentTranslations![key];
    if (translation != null) {
      return translation;
    } else {
      // If translation not found, return the key itself
      return key;
    }
  }
}
