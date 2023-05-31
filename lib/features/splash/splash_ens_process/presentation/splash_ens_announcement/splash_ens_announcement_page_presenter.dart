import 'package:datadashwallet/core/core.dart';
import 'splash_ens_announcement_page_state.dart';

final splashENSAnnouncementPageContainer = PresenterContainer<
    SplashENSAnnouncementPagePresenter,
    SplashENSAnnouncementPageState>(() => SplashENSAnnouncementPagePresenter());

class SplashENSAnnouncementPagePresenter
    extends CompletePresenter<SplashENSAnnouncementPageState> {
  SplashENSAnnouncementPagePresenter() : super(SplashENSAnnouncementPageState());

}
