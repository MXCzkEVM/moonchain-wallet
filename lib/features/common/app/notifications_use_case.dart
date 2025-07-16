import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/app/app_links_use_case.dart';

class MoonchainNotificationsUseCase extends ReactiveUseCase {
  MoonchainNotificationsUseCase(this._moonchainAppLinksUseCase);

  final MoonchainAppLinksUseCase _moonchainAppLinksUseCase;


  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupHandlers() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    handleNotificationData(initialMessage?.data);

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((event) => handleNotificationData(event.data));

    // Foreground message handling 
    // See If there are any openUrl
    // Used to handle when app is opened 
    // FirebaseMessaging.onMessage.listen(handleNotificationData);

    MoonchainWalletNotification.foregroundNotificationStreamController.stream.listen((event) => handleNotificationData(jsonDecode(event!)));
  }

  void handleNotificationData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return;
    }

    if (data['openUrl'] != null) {
      _moonchainAppLinksUseCase.handleLink(Uri.parse(data['openUrl']!));
    }
  }
}
