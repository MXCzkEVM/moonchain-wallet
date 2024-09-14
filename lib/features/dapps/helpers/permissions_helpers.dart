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

        if (value == 'required') {
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

    bool _serviceEnabled;

    try {
      _serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        await geoLocatorPlatform.getCurrentPosition();
        _serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      }
      return _serviceEnabled;
    } catch (e) {
      return false;
    }
  }
}
