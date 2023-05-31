import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';

import 'splash_setup_wallet_page_state.dart';

final splashSetupWalletPageContainer = PresenterContainer<
    SplashSetupWalletPagePresenter,
    SplashSetupWalletPageState>(() => SplashSetupWalletPagePresenter());

class SplashSetupWalletPagePresenter
    extends SplashBasePagePresenter<SplashSetupWalletPageState> {
  SplashSetupWalletPagePresenter() : super(SplashSetupWalletPageState());
}
