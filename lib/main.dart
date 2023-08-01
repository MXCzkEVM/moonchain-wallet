import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app.dart';

void collectLog(String line) {
  FlutterLogs.logThis(tag: 'log', logMessage: line);
}

void reportErrorAndLog(FlutterErrorDetails details) {
  FlutterLogs.logThis(
    tag: 'error',
    errorMessage: '${details.exception.toString()} ${details.stack}',
  );
}

void main() {
  var onError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    onError?.call(details);
    reportErrorAndLog(details);
  };

  runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final isLoggedIn = authUseCase.loggedIn;

      await Biometric.load();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: DataDashWallet(
            isLoggedIn: isLoggedIn,
          ),
        ),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        collectLog(line);
        parent.print(zone, 'Interceptor: $line');
      },
      handleUncaughtError: (Zone self, ZoneDelegate parent, Zone zone,
          Object error, StackTrace stackTrace) {
        reportErrorAndLog(
            FlutterErrorDetails(exception: error, stack: stackTrace));
        parent.print(zone, '${error.toString()} $stackTrace');
      },
    ),
  );
}
