import 'package:datadashwallet/core/core.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  late final _contractTabUseCase = ref.read(contractUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_contractTabUseCase.online,
        (value) => notify(() => state.online = value));

    listen(_walletUseCase.publicAddress, (value) async {
      final name = await _contractTabUseCase.getName(value);

      notify(() {
        state.accounts = [name];
        state.currentAccount = name;
      });
    });

    loadPage();
  }

  void loadPage() {
    Future.wait([
      _contractTabUseCase.checkConnectionToNetwork(),
      _walletUseCase.getPublicAddress(),
    ]);
  }

  void onAccountChange(String value) =>
      notify(() => state.currentAccount = value);
}
