import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';

final splashImportWalletContainer =
    PresenterContainer<SplashImportWalletPresenter, void>(
        () => SplashImportWalletPresenter());

class SplashImportWalletPresenter extends CompletePresenter<void> {
  SplashImportWalletPresenter() : super(null);

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final TextEditingController mnemonicController = TextEditingController();

  String? validate(String? value) {
    if (!_authUseCase.validateMnemonic(value ?? '')) {
      return translate('recovery_phrase_limit')!;
    }

    return null;
  }

  void confirm() async {
    final value = mnemonicController.text;
    loading = true;

    try {
      _authUseCase.createWallet(value);
      pushSetupEnableBiometricPage(context!);
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }
}
