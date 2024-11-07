import 'dart:async';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

void collectLog(String line) {
  FLog.info(text: line);
}

void reportErrorAndLog(FlutterErrorDetails details) {
  FLog.error(
    text: '${details.exception.toString()} ${details.stack}',
    exception: details.exception,
  );
}

LogsConfig? config;

Future<void> initLogs() async {
  config = FLog.getDefaultConfigurations()
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
  delete30MinutesLogs();
  Timer.periodic(const Duration(minutes: 5), (timer) {
    delete30MinutesLogs();
  });
  applyConfig();
}

void activateNotImportantLogs() {
  config = config!..activeLogLevel = LogLevel.DEBUG;
  applyConfig();
}

void disableNotImportantLogs() {
  config = config!..activeLogLevel = LogLevel.ERROR;
  applyConfig();
}

void applyConfig() {
  FLog.applyConfigurations(config!);
}

void delete30MinutesLogs() {
  FLog.deleteAllLogsByFilter(filters: [
    Filter.lessThan(DBConstants.FIELD_TIME_IN_MILLIS,
        DateTime.now().millisecondsSinceEpoch - 1000 * 60 * 30)
  ]);
}
