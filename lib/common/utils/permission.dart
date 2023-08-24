import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Map<String, Permission> permissions = {
    'notifications': Permission.notification,
    'camera': Permission.camera,
    'storage': Permission.storage,
    'location': Permission.location,
  };

  static void log(String feature, [bool isGranted = true]) {
    debugPrint('$feature permission is ${isGranted ? 'granted' : 'rejected'}.');
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

  static Future<void> requestAllPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.locationAlways,
      Permission.notification,
    ].request();
  }
}
