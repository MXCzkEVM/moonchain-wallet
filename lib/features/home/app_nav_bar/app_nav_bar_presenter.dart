import 'package:datadashwallet/core/core.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(
        _contractUseCase.online, (value) => notify(() => state.online = value));

    listen(_accountUseCase.walletAddress, (value) async {
      if (value != null) {
        final name = await _contractUseCase.getName(value);

        notify(() {
          state.accounts = [name];
          state.currentAccount = name;
        });
      }
    });

    loadPage();
  }

  void loadPage() {
    _contractUseCase.checkConnectionToNetwork();
    _accountUseCase.refreshWallet();
  }

  void onAccountChange(String value) =>
      notify(() => state.currentAccount = value);
}
