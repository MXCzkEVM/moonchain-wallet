import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:f_logs/f_logs.dart';
import 'customer_support_state.dart';

final customerSupportContainer =
    PresenterContainer<CustomerSupportPresenter, CustomerSupportState>(
        () => CustomerSupportPresenter());

class CustomerSupportPresenter extends CompletePresenter<CustomerSupportState> {
  CustomerSupportPresenter() : super(CustomerSupportState());

  final AppinioSocialShare _socialShare = AppinioSocialShare();

  @override
  void initState() {
    super.initState();

    loadPage();
  }

  void exportedLogs() async {
    loading = true;
    try {
      final file = await FLog.exportLogs();
      final newFile = await changeFileName(file, 'axs-wallet.txt');

      await _socialShare.shareToSystem(
        translate('export_logs')!,
        '',
        filePath: newFile.path,
      );

      addMessage(translate('exported_logs_successfully'));
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  Future<File> changeFileName(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  Future<void> loadPage() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }
}
