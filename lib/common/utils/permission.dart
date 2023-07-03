import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<void> requestAllPermissions() async {
    void log(String feature, [bool isGranted = true]) {
      debugPrint(
          '$feature permission is ${isGranted ? "granted" : "rejected"}.');
    }

    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.locationAlways,
      Permission.notification,
    ].request();

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

    if (await Permission.locationAlways.isGranted) {
      log('LocationAlways');
    } else {
      log('LocationAlways', false);
    }

    if (await Permission.notification.isGranted) {
      log('Notification');
    } else {
      log('Notification', false);
    }
  }
}
