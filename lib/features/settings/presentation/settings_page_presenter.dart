import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'settings_page_state.dart';

final settingsContainer = PresenterContainer<SettingsPresenter, SettingsState>(
    () => SettingsPresenter());

class SettingsPresenter extends CompletePresenter<SettingsState> {
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

    _accountUserCase.refreshWallet();
  }

  void copyToClipboard(String text) async {
    FlutterClipboard.copy(text).then((value) => null);
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
      final index = state.accounts.length;
      final newAccount = _authUseCase.addNewAccount(index);
      _accountUserCase.addAccount(newAccount);
      loadCache();

      notify(() => state.isLoading = false);
      navigator?.pop();
    } catch (e, s) {
      addError(e, s);
    }
  }

  void changeAccount(Account item) {
    _accountUserCase.changeAccount(item);
    _authUseCase.changeAccount(item);
    loadCache();

    navigator?.pop();
  }

  void loadCache() {
    _webviewUseCase.clearCache();
  }
}
