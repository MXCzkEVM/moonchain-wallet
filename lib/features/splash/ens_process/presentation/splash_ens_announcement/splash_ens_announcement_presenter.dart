import 'package:datadashwallet/core/core.dart';

final splashENSAnnouncementContainer =
    PresenterContainer<SplashENSAnnouncementPresenter, void>(
        () => SplashENSAnnouncementPresenter());

class SplashENSAnnouncementPresenter extends CompletePresenter<void> {
  SplashENSAnnouncementPresenter() : super(null);
}
