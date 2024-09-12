import 'package:clipboard/clipboard.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

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
}
