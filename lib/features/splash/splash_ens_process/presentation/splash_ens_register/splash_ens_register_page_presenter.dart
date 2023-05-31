import 'package:datadashwallet/core/core.dart';
import 'splash_ens_register_page_state.dart';

final splashENSRegisterPageContainer = PresenterContainer<
    SplashENSRegisterPagePresenter,
    SplashENSRegisterPageState>(() => SplashENSRegisterPagePresenter());

class SplashENSRegisterPagePresenter
    extends CompletePresenter<SplashENSRegisterPageState> {
  SplashENSRegisterPagePresenter() : super(SplashENSRegisterPageState());

}
