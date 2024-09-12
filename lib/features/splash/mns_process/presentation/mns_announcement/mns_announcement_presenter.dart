import 'package:moonchain_wallet/core/core.dart';

final splashMNSAnnouncementContainer =
    PresenterContainer<SplashMNSAnnouncementPresenter, void>(
        () => SplashMNSAnnouncementPresenter());

class SplashMNSAnnouncementPresenter extends CompletePresenter<void> {
  SplashMNSAnnouncementPresenter() : super(null);
}
