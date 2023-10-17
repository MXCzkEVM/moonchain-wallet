import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/domain/webview_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'import_account_state.dart';

final importAccountContainer =
    PresenterContainer<ImportAccountPresenter, ImportAccountState>(
        () => ImportAccountPresenter());

class ImportAccountPresenter extends CompletePresenter<ImportAccountState> {
  ImportAccountPresenter() : super(ImportAccountState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _webviewUseCase = WebviewUseCase();

  final TextEditingController privateKeyController = TextEditingController();

  void onSave() async {
    loading = true;
    try {
      final index = _accountUserCase.findAccountsLastIndex();
      final privateKey = privateKeyController.text;

      final newAccount =
          await _authUseCase.addCustomAccount('${index + 1}', privateKey);
      _accountUserCase.addAccount(newAccount);
      loadCache();

      notify(() => state.isLoading = false);
      BottomFlowDialog.of(context!).close();
      navigator?.popUntil((route) {
        return route.settings.name?.contains('SettingsPage') ?? false;
      });
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  void changeAbleToSave(bool value) {
    notify(() => state.ableToSave = value);
  }

  void loadCache() {
    _webviewUseCase.clearCache();
  }
}
