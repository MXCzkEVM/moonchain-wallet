import 'dart:async';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';

import 'import_wallet_state.dart';

final splashImportWalletContainer =
    PresenterContainer<SplashImportWalletPresenter, SplashImportWalletState>(
        () => SplashImportWalletPresenter());

class SplashImportWalletPresenter
    extends CompletePresenter<SplashImportWalletState> {
  SplashImportWalletPresenter() : super(SplashImportWalletState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  @override
  Future<void> dispose() async {
    // state.mnemonicController.dispose();
    super.dispose();
  }

  void validate() {
    final value = state.mnemonicController.text;
    String? result;

    if (!_walletUseCase.validateMnemonic(value)) {
      result = 'recovery_phrase_limit';
    }

    notify(() => state.errorText = result);
  }

  void confirm() {
    final value = state.mnemonicController.text;

    _walletUseCase.setupFromMnemonic(value);
    pushSetupEnableBiometricPage(context!);
  }
}
