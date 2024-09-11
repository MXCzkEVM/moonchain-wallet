import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';

final splashStorageContainer =
    PresenterContainer<SplashStoragePresenter, SplashBaseState>(
        () => SplashStoragePresenter());

class SplashStoragePresenter extends SplashBasePresenter<SplashBaseState> {
  SplashStoragePresenter() : super(SplashBaseState());

  @override
  void initState() {
    super.initState();
    isInstallApps();
    checkEmailAppAvailability();
  }
}
