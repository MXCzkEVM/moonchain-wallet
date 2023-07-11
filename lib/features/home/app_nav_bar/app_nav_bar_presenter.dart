import 'package:datadashwallet/core/core.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_walletUseCase.publicAddress, (value) {
      notify(() {
        state.accounts = [value];
        state.currentAccount = value;
      });
    });

    _walletUseCase.getPublicAddress();
  }

  void onAccountChange(String value) =>
      notify(() => state.currentAccount = value);
}
