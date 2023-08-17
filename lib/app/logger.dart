import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';

void collectLog(String line) {
  FlutterLogs.logThis(tag: 'log', logMessage: line);
}

void reportErrorAndLog(FlutterErrorDetails details) {
  FlutterLogs.logThis(
    tag: 'error',
    errorMessage: '${details.exception.toString()} ${details.stack}',
  );
}

Future<void> initLogs() async {
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
    logsWriteDirectoryName: 'AxsWalletLog',
    logsExportDirectoryName: 'AxsWalletLog/Exported',
    isDebuggable: false,
    autoClearLogs: false,
  );
}
