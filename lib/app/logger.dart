import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

void collectLog(String line) {
  FLog.info(text: line);
}

void reportErrorAndLog(FlutterErrorDetails details) {
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

  FLog.applyConfigurations(config);
}
