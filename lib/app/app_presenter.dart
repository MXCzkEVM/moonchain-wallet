import 'package:moonchain_wallet/core/core.dart';

import 'logger.dart';

final appContainer =
    PresenterContainer<AppPresenter, void>(() => AppPresenter());

class AppPresenter extends CompletePresenter {
  AppPresenter() : super(null);

  late final _logsConfigUseCase = ref.read(logsConfigUseCaseProvider);

  @override
  void initState() {
    super.initState();
    MoonchainWalletFireBase.initLocalNotificationsAndListeners();

    listen(_logsConfigUseCase.notImportantLogsEnabled, (value) {
      if (value) {
        activateNotImportantLogs();
      } else {
        disableNotImportantLogs();
      }
    });
  }
}
