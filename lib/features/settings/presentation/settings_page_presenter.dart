import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../common/common.dart';
import 'settings_page_state.dart';

final settingsContainer = PresenterContainer<SettingsPresenter, SettingsState>(
    () => SettingsPresenter());

class SettingsPresenter extends CompletePresenter<SettingsState>
   {
  SettingsPresenter() : super(SettingsState()); 
  late final _webviewUseCase = WebviewUseCase();
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);

  @override
  void initState() {
    super.initState();
    getAppVersion();


    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.account = value);
      }
    });

    listen(_accountUserCase.accounts, (value) {
      notify(() => state.accounts = value);
    });
  }

  void copyToClipboard(String text) async {
    FlutterClipboard.copy(text).then((value) => null);

    showSnackBar(
        context: context!, content: FlutterI18n.translate(context!, 'copied'));
  }

  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    notify(() => state.appVersion = ' $version ($buildNumber)');
  }

  void addNewAccount() async {
    notify(() => state.isLoading = true);

    try {
      final index = _accountUserCase.findAccountsLastIndex();

      final newAccount = await _authUseCase.addNewAccount(index);
      _accountUserCase.addAccount(newAccount, index: index);
      loadCache();

      notify(() => state.isLoading = false);
      navigator?.popUntil((route) {
        return route.settings.name?.contains('SettingsPage') ?? false;
      });
    } catch (e, s) {
      addError(e, s);
    }
  }

  void changeAccount(Account item, {bool shouldPop = true}) {
    _accountUserCase.changeAccount(item);
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
        _accountUserCase.removeAccount(item);

        final isSelected = _accountUserCase.isAccountSelected(item);
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
