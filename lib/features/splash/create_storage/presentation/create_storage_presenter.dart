import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/splash/splash.dart';

import 'widgets/confirm_storage_dialog.dart';

final splashStorageContainer =
    PresenterContainer<SplashStoragePresenter, SplashBaseState>(
        () => SplashStoragePresenter());

class SplashStoragePresenter extends SplashBasePresenter<SplashBaseState> {
  SplashStoragePresenter() : super(SplashBaseState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void showSaveToAppDialog(String keys,
      {StorageType type = StorageType.others}) {
    showConfirmStorageAlertDialog(context!, type: type, onOkTap: () {
      _walletUseCase.setupFromMnemonic(keys);

      pushPasscodeSetPage(context!);
    });
  }

  
}
