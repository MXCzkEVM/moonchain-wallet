import 'dart:convert';

import 'package:moonchain_wallet/core/src/firebase/moonchain_wallet_firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MoonchainWalletNotification {
  static MoonchainWalletNotification? _instance;

  MoonchainWalletNotification._();

  factory MoonchainWalletNotification() {
    _instance ??= MoonchainWalletNotification._();
    return _instance!;
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;
  late AndroidNotificationChannel lowPriorityChannel;

  bool isFlutterLocalNotificationsInitialized = false;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> setupFlutterNotifications(
      {bool shouldInitFirebase = true}) async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'moonchain_wallet_channel',
      'Moonchain wallet notifications Channel',
      description:
          'This channel is related to Moonchain wallet app notifications.',
      importance: Importance.high,
    );

    lowPriorityChannel = const AndroidNotificationChannel(
      'moonchain_wallet_low_priority_channel',
      'Moonchain wallet low priority notifications channel',
      description:
          'This channel is related to Moonchain wallet app notifications.',
      importance: Importance.low,
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
      await MoonchainWalletFireBase
          .setForegroundNotificationPresentationOptions();
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
        base64Encode(response.bodyBytes),
      );
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
            groupKey: 'moonchain_wallet',
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            visibility: NotificationVisibility.public,
            icon: 'moonchain_logo',
            color: Colors.black,
            largeIcon: largeImage,
          ),
        ),
      );
    }
  }

  void showNotification(String title, String? text) {
    if (!kIsWeb) {
      BigTextStyleInformation? bigTextStyleInformation;
      if (text != null && text.isNotEmpty) {
        bigTextStyleInformation = BigTextStyleInformation(text);
      }

      flutterLocalNotificationsPlugin.show(
        title.hashCode,
        title,
        text,
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              groupKey: 'moonchain_wallet',
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              visibility: NotificationVisibility.public,
              icon: 'moonchain_logo',
              color: Colors.black,
              largeIcon: null,
              styleInformation: bigTextStyleInformation),
        ),
      );
    }
  }

  void showLowPriorityNotification(String title, String? text) {
    if (!kIsWeb) {
      BigTextStyleInformation? bigTextStyleInformation;
      if (text != null && text.isNotEmpty) {
        bigTextStyleInformation = BigTextStyleInformation(text);
      }
      flutterLocalNotificationsPlugin.show(
        title.hashCode,
        title,
        text,
        NotificationDetails(
          android: AndroidNotificationDetails(
              lowPriorityChannel.id, lowPriorityChannel.name,
              groupKey: 'moonchain_wallet_low_priority',
              channelDescription: channel.description,
              importance: Importance.low,
              priority: Priority.low,
              playSound: true,
              visibility: NotificationVisibility.public,
              icon: 'moonchain_logo',
              color: Colors.black,
              largeIcon: null,
              styleInformation: bigTextStyleInformation),
        ),
      );
    }
  }
}
