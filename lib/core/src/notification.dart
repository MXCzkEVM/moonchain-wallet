import 'dart:convert';

import 'package:datadashwallet/core/src/firebase/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:http/http.dart' as http;

class AXSNotification {
  static AXSNotification? _instance;

  AXSNotification._();

  factory AXSNotification() {
    _instance ??= AXSNotification._();
    return _instance!;
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> setupFlutterNotifications(
      {bool shouldInitFirebase = true}) async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'axs_wallet_channel',
      'AXS Notifications Cannel',
      description: 'This channel is related to AXS wallet app notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    if (shouldInitFirebase) {
      await AXSFireBase.setForegroundNotificationPresentationOptions();
    }

    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    final imageUrl = android?.imageUrl;
    AndroidBitmap<Object>? largeImage;
    if (imageUrl != null) {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      largeImage = ByteArrayAndroidBitmap.fromBase64String(
          base64Encode(response.bodyBytes));
    }
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            groupKey: 'axs_wallet',
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            visibility: NotificationVisibility.public,
            icon: 'axs_logo',
            color: ColorsTheme.primary300,
            largeIcon: largeImage,
          ),
        ),
      );
    }
  }

  void showNotification(String title, String text) {
    if (!kIsWeb) {
      var bigTextStyleInformation = BigTextStyleInformation(text);
      flutterLocalNotificationsPlugin.show(
        title.hashCode,
        title,
        text,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                groupKey: 'axs_wallet',
                channelDescription: channel.description,
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
                visibility: NotificationVisibility.public,
                icon: 'axs_logo',
                color: ColorsTheme.primary300,
                largeIcon: null,
                styleInformation: bigTextStyleInformation),
            iOS: DarwinNotificationDetails(
              subtitle: text,
            )),
      );
    }
  }
}
