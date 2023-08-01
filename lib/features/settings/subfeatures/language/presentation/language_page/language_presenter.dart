import 'dart:ui';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'language_state.dart';

final languageContainer = PresenterContainer<LanguagePresenter, LanguageState>(
    () => LanguagePresenter());

class LanguagePresenter extends CompletePresenter<LanguageState> {
  LanguagePresenter() : super(LanguageState());

  late final LanguageUseCase _languageUseCase =
      ref.read(languageUseCaseProvider);

  @override
  void initState() {
    super.initState();
    state.languages = _languageUseCase.supportedLocales;
    listen<Language?>(
      _languageUseCase.currentLocale,
      (v) => notify(
        () => state.currentLanguage = v ?? const Language('en', 'English'),
      ),
    );
  }

  Future<void> changeLanguage(Language? language) async {
    _languageUseCase.setCurrentLocale(language);
    notify();
    await FlutterI18n.refresh(
      context!,
      language?.code == null ? const Locale('en') : Locale(language!.code),
    );
  }
}
