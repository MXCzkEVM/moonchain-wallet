import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../dapp_hooks_state.dart';
import '../domain/dapp_hooks_use_case.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../widgets/location_permission_bottom_sheet.dart';

class WiFiHooksHelper {
  WiFiHooksHelper(
      {required this.state,
      required this.dAppHooksUseCase,
      required this.geoLocatorPlatform,
      required this.context,
      required this.translate});
  DAppHooksUseCase dAppHooksUseCase;
  DAppHooksState state;
  geo.GeolocatorPlatform geoLocatorPlatform;
  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  BuildContext? context;
  String? Function(String) translate;
  StreamSubscription<geo.ServiceStatus>? locationServiceStateStreamSubscription;

  initLocationServiceStateStream() {
    Stream<geo.ServiceStatus> locationStateStream =
        geoLocatorPlatform.getServiceStatusStream();

    locationServiceStateStreamSubscription =
        locationStateStream.listen((status) {
      checkWifiHookEnabled();
    });

    checkWifiHookEnabled();
  }

  void changeWifiHooksEnabled(bool value) {
    if (value) {
      checkWifiHooksRequirements();
    } else {
      dAppHooksUseCase.updatedWifiHooksEnabled(value);
    }
  }

  Future<void> checkWifiHooksRequirements() async {
    final isGranted = await PermissionUtils.initLocationPermission();

    if (isGranted) {
      final isServiceEnabled = await enableLocationService();
      if (isServiceEnabled) {
        dAppHooksUseCase.setLocationSettings();
      }
      dAppHooksUseCase.updatedWifiHooksEnabled(isServiceEnabled);
    } else {
      dAppHooksUseCase.updatedWifiHooksEnabled(false);
      // Looks like the notification is blocked permanently
      showLocationPermissionBottomSheet(
          context: context!, openLocationSettings: openLocationSettings);
    }
  }

  // Checks if wifi hooks enabled, If enabled starts location service
  void checkWifiHookEnabled() {
    if (state.dAppHooksData!.wifiHooks.enabled &&
        state.dAppHooksData!.enabled) {
      checkWifiHooksRequirements();
    }
  }

  Future<bool> enableLocationService() async {
    ServiceStatus locationServiceStatus =
        await Permission.location.serviceStatus;
    bool locationServiceEnabled = locationServiceStatus.isEnabled;
    if (!locationServiceEnabled) {
      try {
        await geoLocatorPlatform.getCurrentPosition();
        return true;
      } catch (e) {
        dappHooksSnackBarUtils.showLocationServiceServiceFailureSnackBar();
        return false;
      }
    }
    return true;
  }

  void openLocationSettings() {
    if (Platform.isAndroid) {
      AppSettings.openAppSettings(
          type: AppSettingsType.location, asAnotherTask: false);
    } else {
      // IOS
      AppSettings.openAppSettings(
        type: AppSettingsType.settings,
      );
    }
  }
}
