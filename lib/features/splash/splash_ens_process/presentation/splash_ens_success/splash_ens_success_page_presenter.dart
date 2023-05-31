import 'package:datadashwallet/core/core.dart';
import 'splash_ens_success_page_state.dart';

final splashENSSuccessPageContainer = PresenterContainer<
    SplashENSSuccessPagePresenter,
    SplashENSSuccessPageState>(() => SplashENSSuccessPagePresenter());

class SplashENSSuccessPagePresenter
    extends CompletePresenter<SplashENSSuccessPageState> {
  SplashENSSuccessPagePresenter() : super(SplashENSSuccessPageState());

}
