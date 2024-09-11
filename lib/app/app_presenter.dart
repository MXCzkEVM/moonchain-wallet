import 'package:moonchain_wallet/core/core.dart';

final appContainer =
    PresenterContainer<SettingsPresenter, void>(() => SettingsPresenter());

class SettingsPresenter extends CompletePresenter {
  SettingsPresenter() : super(null);

  @override
  void initState() {
    super.initState();
    MoonchainWalletFireBase.initLocalNotificationsAndListeners();
  }
}
