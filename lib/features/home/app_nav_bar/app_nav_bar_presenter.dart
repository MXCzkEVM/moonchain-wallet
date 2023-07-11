import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home/domain/contract_use_case.dart';
import 'package:datadashwallet/features/wallet/domain/wallet_use_case.dart';

import 'app_nav_bar_state.dart';

final appNavBarContainer = PresenterContainer<AppNavPresenter, AppNavBarState>(
    () => AppNavPresenter());

class AppNavPresenter extends CompletePresenter<AppNavBarState> {
  AppNavPresenter() : super(AppNavBarState());

  late final WalletUseCase _walletUseCase = ref.read(walletUseCaseProvider);
  late final ContractUseCase _contractTabUseCase =
      ref.read(contractUseCaseProvider);

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
