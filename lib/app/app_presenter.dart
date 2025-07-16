import 'package:moonchain_wallet/core/core.dart';

import 'logger.dart';

final appContainer =
    PresenterContainer<AppPresenter, void>(() => AppPresenter());

class AppPresenter extends CompletePresenter {
  AppPresenter() : super(null);

  late final _logsConfigUseCase = ref.read(logsConfigUseCaseProvider);
  late final _notificationUseCase = ref.read(notificationUseCaseProvider);

  @override
  void initState() {
    super.initState();
    MoonchainWalletFireBase.initLocalNotificationsAndListeners();
    _notificationUseCase.setupHandlers();

    listen(_logsConfigUseCase.notImportantLogsEnabled, (value) {
      if (value) {
        activateNotImportantLogs();
      } else {
        disableNotImportantLogs();
      }
    });
  }
}
