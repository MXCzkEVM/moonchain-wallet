import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/src/moonchain_wallet_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
export 'firebase_options.dart';

class MoonchainWalletFireBase {
  static MoonchainWalletNotification get moonchainNotification =>
      MoonchainWalletNotification();

  static String? firebaseToken;
  static int buildTap = 0;
  static bool foregroundHandlerInit = false;
  static bool messageInteractionInit = false;
  static bool firebaseInit = false;

  static Future<FirebaseApp> initializeFirebase() async {
    if (firebaseInit) {
      return Firebase.app();
    }
    firebaseInit = true;
    return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // Listening to the foreground messages
  static void _setupFirebaseMessagingForegroundHandler() async {
    if (foregroundHandlerInit) {
      return;
    }

    firebaseToken = Platform.isAndroid
        ? await FirebaseMessaging.instance.getToken()
        : await FirebaseMessaging.instance.getAPNSToken();
    print('TEST: firebaseToken $firebaseToken');
    FirebaseMessaging.onMessage
        .listen(moonchainNotification.showFlutterNotification);
    foregroundHandlerInit = true;
  }

  // It is assumed that all messages contain a data field with the key 'type'
  static Future<void> setupFirebaseMessageInteraction() async {
    if (messageInteractionInit) {
      return;
    }

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    messageInteractionInit = true;
  }

  static void _handleMessage(RemoteMessage message) {
    // Check what is inside the message object
    RemoteNotification? notification = message.notification;
    //AndroidNotification? android = message.notification?.android;

    print("notification: $notification");
    print("message data: ${message.data}");
  }

  static Future<void> setForegroundNotificationPresentationOptions() async {
    return await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Initializes firebaseMessageInteraction (For when user taps on notification) if user grants the permission, Otherwise the local notification & firebaseMessageInteraction are not going to be set.
  static Future<void> initLocalNotificationsAndListeners() async {
    final isPermissionGranted = await _initLocalNotifications();
    if (isPermissionGranted) {
      _setupFirebaseMessagingForegroundHandler();
      setupFirebaseMessageInteraction();
    }
  }

  /// Initializes local notifications if permission is granted, Otherwise the local notification is not going to be set.
  static Future<bool> _initLocalNotifications() async {
    final isGranted = await PermissionUtils.initNotificationPermission();
    if (isGranted) {
      await moonchainNotification.setupFlutterNotifications();
    }
    return isGranted;
  }

  static void incrementBuildTap() async {
    buildTap++;
    if (buildTap == 10) {
      forceFullCrash();
    }
     else {
      forceCrash();
    }
    if (buildTap == 10) {
      final token = await FirebaseMessaging.instance.getToken();
      FlutterClipboard.copy(token ?? 'Unable to get token');
      buildTap = 0;
    }
  }

  static void forceCrash() {
    throw Exception("Test crash to verify Firebase Crashlytics integration.");
  }

  static void forceFullCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
