import 'dart:io';

import 'package:datadashwallet/core/core.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'customer_support_state.dart';

final customerSupportContainer =
    PresenterContainer<CustomerSupportPresenter, CustomerSupportState>(
        () => CustomerSupportPresenter());

class CustomerSupportPresenter extends CompletePresenter<CustomerSupportState> {
  CustomerSupportPresenter() : super(CustomerSupportState());

  @override
  void initState() {
    super.initState();

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        var zipName = call.arguments.toString();

        Directory? externalDirectory;

        if (Platform.isIOS) {
          externalDirectory = await getApplicationDocumentsDirectory();
        } else {
          externalDirectory = await getExternalStorageDirectory();
        }

        FlutterLogs.logInfo(
            'export', 'found', 'External Storage:$externalDirectory');

        File file = File('${externalDirectory!.path}/$zipName');

        FlutterLogs.logInfo(
            'export', 'path', 'Path: \n${file.path.toString()}');

        if (file.existsSync()) {
          FlutterLogs.logInfo(
              'export', 'existsSync', 'Logs found and ready to export!');

          notify(() => state.exportedLogsPath = file.path);
        } else {
          FlutterLogs.logError(
              'export', 'existsSync', 'File not found in storage.');
        }
      }
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void exportedLogs() async {
    loading = true;
    try {
      // FlutterLogs.exportLogs(exportType: ExportType.ALL);
      final file = await FLog.exportLogs();
      print(file.absolute);
      notify(() => state.exportedLogsPath = file.absolute.path);
      addMessage(translate('exported_logs_successfully'));
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }
}
