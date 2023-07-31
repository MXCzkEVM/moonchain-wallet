import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';

class AppLogWrapper extends StatefulWidget {
  const AppLogWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<AppLogWrapper> createState() => _AppLogWrapperState();
}

class _AppLogWrapperState extends State<AppLogWrapper> {
  String filePath = '';

  @override
  void initState() {
    super.initState();

    initLogs();
  }

  void initLogs() async {
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ['error'],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: 'DatadashWalletLog',
      logsExportDirectoryName: 'DatadashWalletLog/Exported',
      isDebuggable: false,
      autoClearLogs: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
