import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';

final splashStorageContainer =
    PresenterContainer<SplashStoragePresenter, SplashBaseState>(
        () => SplashStoragePresenter());

class SplashStoragePresenter extends SplashBasePresenter<SplashBaseState> {
  SplashStoragePresenter() : super(SplashBaseState());

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }
}
