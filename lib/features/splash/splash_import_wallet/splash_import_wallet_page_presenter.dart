import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'splash_import_wallet_page_state.dart';

final splashImportWalletPageContainer = PresenterContainer<
    SplashImportWalletPagePresenter,
    SplashImportWalletPageState>(() => SplashImportWalletPagePresenter());

class SplashImportWalletPagePresenter
    extends CompletePresenter<SplashImportWalletPageState> {
  SplashImportWalletPagePresenter() : super(SplashImportWalletPageState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  late final TextEditingController _mnemonicController =
      useTextEditingController();

  @override
  Future<void> dispose() {
    _mnemonicController.dispose();
    return super.dispose();
  }

  void confirm() {
    String keys = _mnemonicController.text;
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
