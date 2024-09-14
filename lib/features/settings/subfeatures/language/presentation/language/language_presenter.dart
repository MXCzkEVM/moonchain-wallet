import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:flutter/material.dart';

import 'language_state.dart';

final languageContainer = PresenterContainer<LanguagePresenter, LanguageState>(
    () => LanguagePresenter());

class LanguagePresenter extends CompletePresenter<LanguageState> {
  LanguagePresenter() : super(LanguageState());

  late final LanguageUseCase _useCase = ref.read(languageUseCaseProvider);

  @override
  void initState() {
    super.initState();
    state.supportedLanguages = _useCase.supportedLocales;
    listen<Language?>(
      _useCase.currentLocale,
      (v) => notify(() => state.language = v),
    );
  }
}
