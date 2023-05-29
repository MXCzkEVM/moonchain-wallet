import 'package:datadashwallet/core/core.dart';
import 'splash_import_wallet_page_state.dart';


final splashImportWalletPageContainer = PresenterContainer<
    SplashImportWalletPagePresenter,
    SplashImportWalletPageState>(() => SplashImportWalletPagePresenter());

class SplashImportWalletPagePresenter
    extends CompletePresenter<SplashImportWalletPageState> {
  SplashImportWalletPagePresenter() : super(SplashImportWalletPageState());
}
