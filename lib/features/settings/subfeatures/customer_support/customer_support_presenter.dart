import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:f_logs/f_logs.dart';
import 'customer_support_state.dart';

final customerSupportContainer =
    PresenterContainer<CustomerSupportPresenter, CustomerSupportState>(
        () => CustomerSupportPresenter());

class CustomerSupportPresenter extends CompletePresenter<CustomerSupportState> {
  CustomerSupportPresenter() : super(CustomerSupportState());

  final AppinioSocialShare _socialShare = AppinioSocialShare();
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _logsConfigUseCase = ref.read(logsConfigUseCaseProvider);

  @override
  void initState() {
    super.initState();

    _logsConfigUseCase.notImportantLogsEnabled.listen(
      (value) => notify(
        () => state.notImportantLogsEnabled = value,
      ),
    );

    loadPage();
  }

  void changeNotImportantLogsEnabled(bool value) =>
      _logsConfigUseCase.updateItem(value);

  void exportedLogs() async {
    loading = true;

    // If we have lots of logs
    if (state.notImportantLogsEnabled == true) {
      await Future.delayed(
        const Duration(seconds: 5),
      );
    }
    try {
      final file = await FLog.exportLogs();
      final newFile = await changeFileName(
        file,
        'Moonbase-log.txt',
      );

      final Size size = MediaQuery.of(context!).size;

      await Share.shareXFiles([
        XFile(
          newFile.path,
          mimeType: 'text/plain',
        )
      ],
          subject: translate('export_logs'),
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, size.width, size.height / 2));

      addMessage(translate('exported_logs_successfully'));
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  Future<File> changeFileName(File file, String newFileName) async {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return (await file.rename(newPath));
  }

  Future<void> loadPage() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }

  Future<void> launchMoonchainSupportBot() async {
    return _launcherUseCase.launchMoonchainSupportBot();
  }

  Future<void> launchMXCKnowledgeHub() async {
    return _launcherUseCase.launchMoonchainWebsite();
  }

  Future<void> launchMXCDesignDocs() async {
    return _launcherUseCase.launchMoonchainDesignDocs();
  }
}
