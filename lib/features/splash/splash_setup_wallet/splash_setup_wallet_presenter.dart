import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';

import 'splash_setup_wallet_state.dart';

final splashSetupWalletContainer = PresenterContainer<
    SplashSetupWalletPresenter,
    SplashSetupWalletState>(() => SplashSetupWalletPresenter());

class SplashSetupWalletPresenter
    extends SplashBasePresenter<SplashSetupWalletState> {
  SplashSetupWalletPresenter() : super(SplashSetupWalletState());
}
