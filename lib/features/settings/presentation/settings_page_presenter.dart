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
      final index = findAccountLastIndex(state.accounts);
      // final index = state.accounts.length;
      final newAccount = await _authUseCase.addNewAccount(index);
      // final newAccount = await _authUseCase.addCustomAccount('index' ,'6373f6b31ccb382ea61f02a89c28d88972bdc8a45ea0d817826c097188832b3c');
      _accountUserCase.addAccount(newAccount);
      loadCache();

      notify(() => state.isLoading = false);
      navigator?.pop();
    } catch (e, s) {
      addError(e, s);
    }
  }

  int findAccountLastIndex(List<Account> accounts) {
    int lastIndex = 0;
    for (Account account in accounts.reversed) {
      if (!account.isCustom) {
        lastIndex = int.parse(account.name);
        break;
      }
    }
    return lastIndex;
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
