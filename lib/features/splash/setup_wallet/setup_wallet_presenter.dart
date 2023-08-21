import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'setup_wallet_state.dart';

final splashSetupWalletContainer =
    PresenterContainer<SplashSetupWalletPresenter, SplashSetupWalletState>(
        () => SplashSetupWalletPresenter());

class SplashSetupWalletPresenter
    extends SplashBasePresenter<SplashSetupWalletState> {
  SplashSetupWalletPresenter() : super(SplashSetupWalletState());
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  @override
  void initState() {
    listen(_chainConfigurationUseCase.networks, (value) {
      if (value.isEmpty) {
        // populates the default list for the first time
        final defaultList = Network.fixedNetworks();
        _chainConfigurationUseCase.addItems(defaultList);
      }
    });
    super.initState();
  }
}
