import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_accountUseCase.account, (account) async {
      if (account != null) {
        updateAccount(account);

        if (account.mns == null) {
          final mns = await _tokenContractUseCase.getName(account.address);
          account.mns = mns;
          _accountUseCase.updateAccount(account);
        }
      }
    });

    loadPage();
  }

  void updateAccount(Account value) {
    notify(() => state.account = value);
  }

  void loadPage() {
    _tokenContractUseCase.checkConnectionToNetwork();
    _accountUseCase.refreshWallet();
  }
}
