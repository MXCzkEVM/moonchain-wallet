import 'dart:ui';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'language_page_state.dart';

final languageContainer =
    PresenterContainer<LanguagePagePresenter, LanguagePageState>(
        () => LanguagePagePresenter());

class LanguagePagePresenter extends CompletePresenter<LanguagePageState> {
  LanguagePagePresenter() : super(LanguagePageState());

  late final LanguageUseCase _languageUseCase =
      ref.read(languageUseCaseProvider);

  @override
  void initState() {
    super.initState();
    state.languages = _languageUseCase.supportedLocales;
    listen<Language?>(
      _languageUseCase.currentLocale,
      (v) => notify(() => state.currentLanguage = v),
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
