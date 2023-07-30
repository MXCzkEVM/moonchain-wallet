import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/security/widgets/delet_wallet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'security_settings_state.dart';

final securitySettingsContainer =
    PresenterContainer<SecuritySettingsPresenter, SecuritySettingsState>(
        () => SecuritySettingsPresenter());

class SecuritySettingsPresenter
    extends CompletePresenter<SecuritySettingsState> {
  SecuritySettingsPresenter() : super(SecuritySettingsState());

  late final TextEditingController yesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void clearBrowserCache() async {
    final result = await showAlertDialog(
      context: context!,
      title: translate('delete_wallet_note')!,
      content: translate('clear_browser_warning')!,
      ok: translate('clear')!,
    );

    if (result != null && result) {
      showSnackBar(
        context: context!,
        content: 'clear_browser_successfully',
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
      //todo
      //delete wallet
    }
  }
}
