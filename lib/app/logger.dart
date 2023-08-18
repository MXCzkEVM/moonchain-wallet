import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_logs/flutter_logs.dart';

void collectLog(String line) {
  // FlutterLogs.logThis(tag: 'log', logMessage: line);
  FLog.info(text: line);
}

void reportErrorAndLog(FlutterErrorDetails details) {
  // FlutterLogs.logThis(
  //   tag: 'error',
  //   errorMessage: '${details.exception.toString()} ${details.stack}',
  // );
  FLog.error(
    text: '${details.exception.toString()} ${details.stack}',
    exception: details.exception,
  );
}

Future<void> initLogs() async {
  LogsConfig config = FLog.getDefaultConfigurations()
    ..isDebuggable = false
    ..isDevelopmentDebuggingEnabled = false
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3
    ..formatType = FormatType.FORMAT_CUSTOM
    ..fieldOrderFormatCustom = [
      FieldName.TIMESTAMP,
      FieldName.LOG_LEVEL,
      FieldName.CLASSNAME,
      FieldName.METHOD_NAME,
      FieldName.TEXT,
      FieldName.EXCEPTION,
      FieldName.STACKTRACE
    ];

  // await FlutterLogs.initLogs(
  //   logLevelsEnabled: [
  //     LogLevel.INFO,
  //     LogLevel.WARNING,
  //     LogLevel.ERROR,
  //     LogLevel.SEVERE,
  //   ],
  //   timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
  //   directoryStructure: DirectoryStructure.FOR_DATE,
  //   logTypesEnabled: ['error', 'network', 'device'],
  //   logFileExtension: LogFileExtension.LOG,
  //   logsWriteDirectoryName: 'AxsWalletLog',
  //   logsExportDirectoryName: 'AxsWalletLog/Exported',
  //   isDebuggable: false,
  //   autoClearLogs: false,
  // );
}
