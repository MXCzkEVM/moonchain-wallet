import 'package:clipboard/clipboard.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';

final splashImportWalletContainer =
    PresenterContainer<SplashImportWalletPresenter, void>(
        () => SplashImportWalletPresenter());

class SplashImportWalletPresenter extends CompletePresenter<void> {
  SplashImportWalletPresenter() : super(null);

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final TextEditingController mnemonicController = TextEditingController();

  String? validate(String? value) {
    final formattedMnemonic =
        MXCFormatter.trimAndRemoveExtraSpaces(value ?? "");

    if (!_authUseCase.validateMnemonic(formattedMnemonic)) {
      return translate('recovery_phrase_limit')!;
    }

    return null;
  }

  void confirm() async {
    final value = mnemonicController.text;
    loading = true;

    try {
      final formattedMnemonic = MXCFormatter.trimAndRemoveExtraSpaces(value);
      final account = await _authUseCase.addAccount(formattedMnemonic);
      _accountUseCase.addAccount(account);
      pushSetupEnableBiometricPage(context!);
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  void pastFromClipBoard() async {
    mnemonicController.text = await FlutterClipboard.paste();
    mnemonicController.selection = TextSelection.fromPosition(
        TextPosition(offset: mnemonicController.text.length));
  }
}
