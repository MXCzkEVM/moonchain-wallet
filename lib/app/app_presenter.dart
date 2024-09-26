import 'package:moonchain_wallet/core/core.dart';

final appContainer =
    PresenterContainer<AppPresenter, void>(() => AppPresenter());

class AppPresenter extends CompletePresenter {
  AppPresenter() : super(null);

  @override
  void initState() {
    super.initState();
    MoonchainWalletFireBase.initLocalNotificationsAndListeners();
  }
}
