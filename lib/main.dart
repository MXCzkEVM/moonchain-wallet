import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app.dart';

const appName = 'MOONCHAIN';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print(message.data);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MoonchainWalletNotification().setupFlutterNotifications();
  // Firebase triggers notifications Itself
  // mxcNotification.showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      const fatalError = true;
      var onError = FlutterError.onError;
      // Non-async exceptions
      FlutterError.onError = (errorDetails) {
        onError?.call(errorDetails);
        reportErrorAndLog(errorDetails);
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        }
      };
      // Async exceptions
      PlatformDispatcher.instance.onError = (error, stack) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        return true;
      };

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      await dotenv.load(fileName: 'assets/.env');
      await initLogs();
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final isLoggedIn = authUseCase.loggedIn;

      await Biometric.load();

      final appVersionUseCase = container.read(appVersionUseCaseProvider);
      await appVersionUseCase.checkLatestVersion();

      final initializationUseCase = container.read(chainsUseCaseProvider);
      initializationUseCase.updateChains();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: MXCWallet(
            isLoggedIn: isLoggedIn,
          ),
        ),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        collectLog(line);
        parent.print(zone, line);
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
