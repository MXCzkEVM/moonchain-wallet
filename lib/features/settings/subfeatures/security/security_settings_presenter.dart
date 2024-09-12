import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'security_settings_state.dart';

import 'widgets/delete_wallet_dialog.dart';

final securitySettingsContainer =
    PresenterContainer<SecuritySettingsPresenter, SecuritySettingsState>(
        () => SecuritySettingsPresenter());

class SecuritySettingsPresenter
    extends CompletePresenter<SecuritySettingsState> {
  SecuritySettingsPresenter() : super(SecuritySettingsState());

  late final _webviewUseCase = WebviewUseCase();
  late final _passcodeUseCase = ref.read(passcodeUseCaseProvider);
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final TextEditingController yesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(
      _passcodeUseCase.biometricEnabled,
      (v) => notify(() => state.biometricEnabled = v),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void clearBrowserCache() async {
    final result = await showAlertDialog(
      context: context!,
      title: translate('clear_browser_history_note')!,
      content: translate('clear_browser_warning')!,
      ok: translate('clear')!,
    );

    if (result != null && result) {
      await _webviewUseCase.clearCache();
      showSnackBar(
        context: context!,
        content: translate('clear_browser_successfully')!,
      );
    }
  }

  void deleteWallet() async {
    final result1 = await showWarningDialog(
      context: context!,
      title: translate('confirm_delete_wallet')!,
      content: translate('confirm_delete_wallet_note')!,
      ok: translate('understand_delete')!,
    );

    if (result1 != null && !result1) {
      return;
    }

    final result2 = await showDeleteWalletDialog(
      context: context!,
      controller: yesController,
      hint: translate('type_yes')!,
      title: translate('delete_wallet_warning')!,
      ok: translate('delete_wallet')!,
    );

    if (result2 != null && result2) {
      ref.read(logOutUseCaseProvider).logOut();

      navigator?.replaceAll(
        route(
          const SplashSetupWalletPage(),
        ),
      );
    }
  }

  void changeBiometric(bool value) =>
      _passcodeUseCase.setBiometricEnabled(value);
}
