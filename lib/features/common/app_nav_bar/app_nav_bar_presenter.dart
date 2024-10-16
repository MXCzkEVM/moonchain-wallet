import 'package:clipboard/clipboard.dart';
import 'package:moonchain_wallet/common/dialogs/alert_dialog.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/domain/webview_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final _webviewUseCase = WebviewUseCase();
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_accountUseCase.account, (account) async {
      if (account != null) {
        updateAccount(account);
      }
    });

    listen(_accountUseCase.accounts, (value) {
      notify(() => state.accounts = value);
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) async {
      if (value != null) {
        _accountUseCase.getAccountsNames();
        loadPage();
      }
    });
  }

  void updateAccount(Account value) {
    notify(() => state.account = value);
  }

  void loadPage() {
    _tokenContractUseCase.checkConnectionToNetwork();
    _accountUseCase.getAccountsNames();
  }

  void copy() {
    FlutterClipboard.copy(state.account?.mns ?? state.account!.address);

    final tip = translate('copied_x')!.replaceAll('{0}', translate('address')!);
    addMessage(tip);
  }

  void addNewAccount() async {
    notify(() => state.isLoading = true);

    try {
      final index = _accountUseCase.findAccountsLastIndex();

      final newAccount = await _authUseCase.addNewAccount(index);
      _accountUseCase.addAccount(newAccount, index: index);
      loadCache();

      notify(() => state.isLoading = false);
      navigator!.pop();
    } catch (e, s) {
      addError(e, s);
    }
  }

  void changeAccount(Account item, {bool shouldPop = true}) {
    _accountUseCase.changeAccount(item);
    _authUseCase.changeAccount(item);
    loadCache();

    if (shouldPop) navigator?.pop();
  }

  void removeAccount(Account item) async {
    try {
      final result = await showAlertDialog(
        context: context!,
        title: translate('removing_account')!,
        content: translate('removing_account_warning')!,
        ok: translate('remove')!,
      );

      if (result != null && result) {
        _accountUseCase.removeAccount(item);

        final isSelected = _accountUseCase.isAccountSelected(item);
        if (isSelected) {
          changeAccount(state.accounts[0], shouldPop: false);
        }

        navigator?.pop();
      }
    } catch (e, s) {
      addError(e, s);
    }
  }

  void loadCache() {
    _webviewUseCase.clearCache();
  }
}
