import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:datadashwallet/core/core.dart';
import 'notifications_state.dart';

final notificationsContainer =
    PresenterContainer<NotificationsPresenter, NotificationsState>(
        () => NotificationsPresenter());

class NotificationsPresenter extends CompletePresenter<NotificationsState>
    with WidgetsBindingObserver {
  NotificationsPresenter() : super(NotificationsState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void initState() {
    super.initState();
    checkNotificationsStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // If user went to settings to change notifications state
    if (state == AppLifecycleState.resumed) {
      checkNotificationsStatus();
    }
  }

  void changeNotificationsState(bool shouldEnable) {
    if (shouldEnable) {
      turnNotificationsOn();
    } else {
      turnNotificationsOff();
    }
  }

  void turnNotificationsOn() async {
    final isGranted = await PermissionUtils.initNotificationPermission();
    if (isGranted) {
      // change state
      notify(() => state.isNotificationsEnabled = isGranted);
    } else {
      // Looks like the notification is blocked permanently
      // send to settings
      openNotificationSettings();
    }
  }

  void turnNotificationsOff() {
    openNotificationSettings();
  }

  void openNotificationSettings() {
    if (Platform.isAndroid) {
      AppSettings.openAppSettings(
          type: AppSettingsType.notification, asAnotherTask: false);
    } else {
      // IOS
      AppSettings.openAppSettings(
        type: AppSettingsType.settings,
      );
    }
  }

  void checkNotificationsStatus() async {
    final isGranted = await PermissionUtils.checkNotificationPermission();
    if (state.isNotificationsEnabled == false && isGranted == true) {
      await AXSFireBase.initializeFirebase();
      AXSFireBase.initLocalNotificationsAndListeners();
    } 
    notify(() => state.isNotificationsEnabled = isGranted);
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    return super.dispose();
  }
}
