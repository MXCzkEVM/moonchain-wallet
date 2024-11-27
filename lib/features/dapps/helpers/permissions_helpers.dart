import 'dart:async';
import 'dart:io';

import 'package:moonchain_wallet/common/common.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  PermissionsHelper({
    required this.context,
    required this.notify,
    required this.translate,
  });
  BuildContext? context;
  void Function([void Function()? fun]) notify;
  String? Function(String) translate;

  Future<void> requestPermissions(Dapp dapp) async {
    // Permission request will be only on Android
    if (Platform.isAndroid) {
      final permissions = dapp.app!.permissions!.toMap();
      final keys = permissions.keys.toList();
      final values = permissions.values.toList();
      List<Permission> needPermissions = [];

      for (int i = 0; i < permissions.length; i++) {
        final key = keys[i];
        final value = values[i];

        // Currently since we use OS file picker and import & export are working fine 
        // without storage permission we don't need to request It.
        // Also storage permission is deprecated in Android +13, We will need to 
        // use videos, photos, audio, manageExternalStorage permissions separately 
        // How to use? https://developer.android.com/about/versions/13/behavior-changes-13#granular-media-permissions
        if (value == 'required' && key != 'storage') {
          final permission = PermissionUtils.permissions[key];
          if (permission != null) {
            needPermissions.add(permission);
          }
        }
      }

      if (needPermissions.isNotEmpty) {
        for (Permission permission in needPermissions) {
          await checkPermissionStatusAndRequest(permission);
        }
        await PermissionUtils.permissionsStatus();
      }

      if (keys.contains('location')) {
        await checkLocationService();
      }
    }
  }

  Future<void> checkPermissionStatusAndRequest(
    Permission permission,
  ) async {
    if (!(await PermissionUtils.isPermissionGranted(permission)) &&
        !(await PermissionUtils.isPermissionPermanentlyDenied(permission))) {
      final askForPermission =
          await PermissionUtils.showUseCaseBottomSheet(permission, context!);
      if (askForPermission ?? false) {
        await [permission].request();
      }
    }
  }

  Future<bool> checkLocationService() async {
    final geo.GeolocatorPlatform geoLocatorPlatform =
        geo.GeolocatorPlatform.instance;

    bool serviceEnabled;

    try {
      serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geoLocatorPlatform.getCurrentPosition();
        serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      }
      return serviceEnabled;
    } catch (e) {
      return false;
    }
  }
}
