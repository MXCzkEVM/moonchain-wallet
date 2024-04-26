import 'package:datadashwallet/common/utils/permissions_bottom_sheet.dart';
import 'package:f_logs/f_logs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Map<String, Permission> permissions = {
    'notifications': Permission.notification,
    'camera': Permission.camera,
    'storage': Permission.storage,
    'location': Permission.location,
  };

  static void log(String feature, [bool isGranted = true]) {
    FLog.info(
        text: '$feature permission is ${isGranted ? 'granted' : 'rejected'}.');
  }

  static Future<bool> isPermissionGranted(
    Permission permission,
  ) async {
    return await permission.isGranted;
  }

  static Future<bool> isPermissionPermanentlyDenied(
    Permission permission,
  ) async {
    return await permission.isPermanentlyDenied;
  }

  static Future<bool?> showUseCaseBottomSheet(
      Permission permission, BuildContext context) async {
    return showPermissionUseCasesBottomSheet(context, permission: permission);
  }

  static Future<void> permissionsStatus() async {
    if (await Permission.camera.isGranted) {
      log('Camera');
    } else {
      log('Camera', false);
    }

    if (await Permission.storage.isGranted) {
      log('Storage');
    } else {
      log('Storage', false);
    }

    if (await Permission.location.isGranted) {
      log('Location');
    } else {
      log('Location', false);
    }

    if (await Permission.notification.isGranted) {
      log('Notification');
    } else {
      log('Notification', false);
    }
  }

  static Future<void> requestLocationPermission() async {
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();
  }

  /// Request the notification permission and return the detailed status.
  static Future<AuthorizationStatus> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus;
  }

  /// Return true if the permission is granted (The permission might have some limitation also, In this case It's true also).
  static Future<bool> checkLocationPermission() async {
    PermissionStatus status = await getLocationPermission();

    return status == PermissionStatus.granted;
  }

  static Future<bool> checkNotificationPermission() async {
    AuthorizationStatus authorizationStatus = await getNotificationPermission();

    return authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<bool> checkNotificationPermissionWithAuthorizationStatus(
      AuthorizationStatus authorizationStatus) async {
    return authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<PermissionStatus> getLocationPermission() async {
    PermissionStatus locationStatus = await Permission.location.status;

    return locationStatus;
  }

  static Future<AuthorizationStatus> getNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    return settings.authorizationStatus;
  }

  static Future<bool> initLocationPermission() async {
    PermissionStatus status = await getLocationPermission();
    if (status == PermissionStatus.granted) {
      return true;
    }

    if (status == PermissionStatus.permanentlyDenied) {
      return false;
    }
    // permission not granted or the status is not determined
    await requestLocationPermission();
    final isGranted = await checkLocationPermission();
    return isGranted;
  }

  static Future<bool> initNotificationPermission() async {
    bool isGranted = await checkNotificationPermission();
    if (isGranted) {
      return isGranted;
    }
    // permission not granted or the status is not determined
    final authorizationStatus = await requestNotificationPermission();
    isGranted = await checkNotificationPermissionWithAuthorizationStatus(
        authorizationStatus);
    return isGranted;
  }

  /// Maps a [AuthorizationStatus] to a string value.
  static const statusMap = {
    AuthorizationStatus.authorized: 'Authorized',
    AuthorizationStatus.denied: 'Denied',
    AuthorizationStatus.notDetermined: 'Not Determined',
    AuthorizationStatus.provisional: 'Provisional',
  };

  /// Maps a [AppleNotificationSetting] to a string value.
  static const settingsMap = {
    AppleNotificationSetting.disabled: 'Disabled',
    AppleNotificationSetting.enabled: 'Enabled',
    AppleNotificationSetting.notSupported: 'Not Supported',
  };

  /// Maps a [AppleShowPreviewSetting] to a string value.
  static const previewMap = {
    AppleShowPreviewSetting.always: 'Always',
    AppleShowPreviewSetting.never: 'Never',
    AppleShowPreviewSetting.notSupported: 'Not Supported',
    AppleShowPreviewSetting.whenAuthenticated: 'Only When Authenticated',
  };
}
