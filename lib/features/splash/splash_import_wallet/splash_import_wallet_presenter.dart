import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'splash_import_wallet_state.dart';

final splashImportWalletContainer =
    PresenterContainer<SplashImportWalletPresenter, SplashImportWalletState>(
        () => SplashImportWalletPresenter());

class SplashImportWalletPresenter
    extends CompletePresenter<SplashImportWalletState> {
  SplashImportWalletPresenter() : super(SplashImportWalletState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  void confirm() {
    String keys = state.mnemonicController.text;
    try {
      if (keys.isEmpty) {
        throw Exception('Mnemonic passphrase is empty');
      }

      _walletUseCase.setupFromMnemonic(keys);

      pushPasscodeSetPage(context!);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
