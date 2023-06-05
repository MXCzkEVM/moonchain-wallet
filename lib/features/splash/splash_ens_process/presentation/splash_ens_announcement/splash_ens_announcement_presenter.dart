import 'package:datadashwallet/core/core.dart';
import 'splash_ens_announcement_state.dart';

final splashENSAnnouncementContainer = PresenterContainer<
    SplashENSAnnouncementPresenter,
    SplashENSAnnouncementState>(() => SplashENSAnnouncementPresenter());

class SplashENSAnnouncementPresenter
    extends CompletePresenter<SplashENSAnnouncementState> {
  SplashENSAnnouncementPresenter() : super(SplashENSAnnouncementState());

}
