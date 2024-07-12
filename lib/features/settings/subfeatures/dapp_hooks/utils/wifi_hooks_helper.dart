import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:permission_handler/permission_handler.dart';
import '../dapp_hooks_state.dart';
import '../domain/dapp_hooks_use_case.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../widgets/wifi_hooks_background_fetch_alert_bottom_sheet.dart';
import '../widgets/location_permission_bottom_sheet.dart';

class WiFiHooksHelper {
  WiFiHooksHelper(
      {required this.state,
      required this.dAppHooksUseCase,
      required this.geoLocatorPlatform,
      required this.backgroundFetchConfigUseCase,
      required this.context,
      required this.translate});
  DAppHooksUseCase dAppHooksUseCase;
  DAppHooksState state;
  geo.GeolocatorPlatform geoLocatorPlatform;
  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  BackgroundFetchConfigUseCase backgroundFetchConfigUseCase;
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

  Future<bool> checkWifiHooksRequirements() async {
    final isGranted = await PermissionUtils.initLocationPermission();

    if (isGranted) {
      final isServiceEnabled = await enableLocationService();
      if (isServiceEnabled) {
        dAppHooksUseCase.setLocationSettings();
      }
      return isServiceEnabled;
    } else {
      // Looks like the notification is blocked permanently
      showLocationPermissionBottomSheet(
          context: context!, openLocationSettings: openLocationSettings);
      return false;
    }
  }

  // Checks if wifi hooks enabled, If enabled starts location service
  void checkWifiHookEnabled() {
    if (state.dAppHooksData!.wifiHooks.enabled) {
      checkWifiHooksRequirements();
    }
  }

  void changeWiFiHooksEnabled(bool value) async {
    DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await checkWifiHooksRequirements();
        if (!update) {
          return update;
        }
        update = await startWifiHooksService(
            delay: state.dAppHooksData!.wifiHooks.duration,
            showBGFetchAlert: true);
      } else {
        update = await stopWiFiHooksService(showSnackbar: true);
      }
      return update;
    }, () {
      return dAppHooksUseCase.updatedWifiHooksEnabled(value);
    });
  }

  // delay is in minutes, returns true if success
  Future<bool> startWifiHooksService(
      {required int delay, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      final res =
          await showWiFiHooksBackgroundFetchAlertBottomSheet(context: context!);
      if (res == null || !res) {
        return false;
      }
    }
    final success = await dAppHooksUseCase.startWifiHooksService(delay);
    if (success) {
      dappHooksSnackBarUtils.showWiFiHooksServiceSuccessSnackBar();
    } else {
      dappHooksSnackBarUtils.showWiFiHooksServiceFailureSnackBar();
    }
    return success;
  }

  Future<bool> stopWiFiHooksService({required bool showSnackbar}) async {
    final dappHooksData = dAppHooksUseCase.dappHooksData.value;
    final periodicalCallData =
        backgroundFetchConfigUseCase.periodicalCallData.value;
    final turnOffAll =
        AXSBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData);
    await dAppHooksUseCase.stopWifiHooksService(turnOffAll: turnOffAll);
    if (showSnackbar) {
      dappHooksSnackBarUtils.showWiFiHooksServiceDisableSuccessSnackBar();
    }
    return true;
  }

  void handleFrequencyChange(PeriodicalCallDuration duration) {
    DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      update = await startWifiHooksService(
          delay: duration.toMinutes(), showBGFetchAlert: false);
      return update;
    }, () {
      return dAppHooksUseCase.updateWifiHooksDuration(duration);
    });
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
