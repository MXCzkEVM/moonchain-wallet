import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../settings/settings.dart';
import 'setup_wallet_state.dart';

final splashSetupWalletContainer =
    PresenterContainer<SplashSetupWalletPresenter, SplashSetupWalletState>(
        () => SplashSetupWalletPresenter());

class SplashSetupWalletPresenter
    extends SplashBasePresenter<SplashSetupWalletState> {
  SplashSetupWalletPresenter() : super(SplashSetupWalletState());
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final LanguageUseCase _languageUseCase =
      ref.read(languageUseCaseProvider);

  @override
  void initState() {
    listen(_chainConfigurationUseCase.networks, (value) {
      if (value.isEmpty) {
        // populates the default list for the first time
        final defaultList = Network.fixedNetworks();
        _chainConfigurationUseCase.addItems(defaultList);
      }
    });

    listen<Language?>(
      _languageUseCase.currentLocale,
      (v) {
        if (v == null) {
          try {
            final cLocale = Localizations.maybeLocaleOf(context!);
            final supportedLocales = _languageUseCase.supportedLocales;
            if (cLocale != null) {
              final cLanguage =
                  Language(cLocale.languageCode, cLocale.toLanguageTag());
              if (supportedLocales.contains(cLanguage)) {
                _languageUseCase.setCurrentLocale(cLanguage);
              }
            }
          } catch (e) {}
        }
      },
    );

    super.initState();
  }
}
