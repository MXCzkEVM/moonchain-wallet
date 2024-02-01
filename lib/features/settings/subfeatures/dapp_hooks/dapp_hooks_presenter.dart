import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/widgets/location_permission_bottom_sheet.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/widgets/background_fetch_dialog.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mxc_logic/mxc_logic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dapp_hooks_state.dart';
import 'widgets/dapp_hooks_frequency_dialog.dart';

final notificationsContainer =
    PresenterContainer<DAppHooksPresenter, DAppHooksState>(
        () => DAppHooksPresenter());

class DAppHooksPresenter extends CompletePresenter<DAppHooksState>
    with WidgetsBindingObserver {
  DAppHooksPresenter() : super(DAppHooksState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final geo.GeolocatorPlatform _geoLocatorPlatform =
      geo.GeolocatorPlatform.instance;
  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_dAppHooksUseCase.dappHooksData, (value) {
      checkDAppHooksDataChange(value);
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      notify(() => state.network = value);
    });

    checkLocationServiceEnabled();
  }

  void checkLocationServiceEnabled() async {
    final locationServiceEnabled = await Permission.location.serviceStatus;
    notify(
        () => state.locationServiceEnabled = locationServiceEnabled.isEnabled);
  }

  Future<void> enableLocationService() async {
    ServiceStatus locationServiceStatus =
        await Permission.location.serviceStatus;
    bool locationServiceEnabled = locationServiceStatus.isEnabled;
    if (!locationServiceEnabled) {
      try {
        await _geoLocatorPlatform.getCurrentPosition();
      } catch (e) {
        showLocationServiceServiceFailureSnackBar();
      }
    }
    locationServiceStatus = await Permission.location.serviceStatus;
    locationServiceEnabled = locationServiceStatus.isEnabled;
    notify(() => state.locationServiceEnabled = locationServiceEnabled);
  }

  void changeLocationServiceState(bool value) {
    if (value) {
      enableLocationService();
    } else {
      _geoLocatorPlatform.openLocationSettings();
    }
  }

  void enableDAppHooks(bool value) {
    final newDAppHooksData = state.dAppHooksData!.copyWith(enabled: value);
    _dAppHooksUseCase.updateItem(newDAppHooksData);
  }

  void showDAppHooksFrequency() {
    showDAppHooksFrequencyDialog(context!,
        onTap: handleFrequencyChange,
        selectedFrequency:
            getPeriodicalCallDurationFromInt(state.dAppHooksData!.duration));
  }

  void enableWifiHooks(bool value) {
    final newDAppHooksData = state.dAppHooksData!.copyWith(
        wifiHooks: state.dAppHooksData!.wifiHooks.copyWith(enabled: value));
    _dAppHooksUseCase.updateItem(newDAppHooksData);
  }

  void enableMinerHooks(bool value) {
    final newDAppHooksData = state.dAppHooksData!.copyWith(
        minerHooks: state.dAppHooksData!.minerHooks.copyWith(
      enabled: value,
    ));
    _dAppHooksUseCase.updateItem(newDAppHooksData);
  }

  void changeMinerHookTiming(TimeOfDay value) {
    final newDAppHooksData = state.dAppHooksData!.copyWith(
        minerHooks: state.dAppHooksData!.minerHooks.copyWith(
      time: value,
    ));
    _dAppHooksUseCase.updateItem(newDAppHooksData);
  }

  void handleFrequencyChange(PeriodicalCallDuration duration) {
    final newDAppHooksData =
        state.dAppHooksData!.copyWith(duration: duration.toMinutes());
    _dAppHooksUseCase.updateItem(newDAppHooksData);
  }

  void checkDAppHooksDataChange(DAppHooksModel newDAppHooksData) async {
    bool shouldUpdate = true;

    if (state.dAppHooksData != null) {
      final isDAppHooksServiceChanged =
          state.dAppHooksData!.enabled != newDAppHooksData.enabled;
      final dappHooksServiceDurationChanged =
          state.dAppHooksData!.duration != newDAppHooksData.duration;

      if (isDAppHooksServiceChanged && newDAppHooksData.enabled == true) {
        shouldUpdate = await startDAppHooksService(
            delay: newDAppHooksData.duration, showBGFetchAlert: true);
      } else if (isDAppHooksServiceChanged &&
          newDAppHooksData.enabled == false) {
        shouldUpdate = await stopDAppHooksService(showSnackbar: true);
      } else if (dappHooksServiceDurationChanged) {
        shouldUpdate = await startDAppHooksService(
            delay: newDAppHooksData.duration, showBGFetchAlert: false);
      }
    }

    if (shouldUpdate) {
      notify(() => state.dAppHooksData = newDAppHooksData);
    } else {
      _dAppHooksUseCase.updateItem(state.dAppHooksData!);
    }
  }

  // delay is in minutes, returns true if success
  Future<bool> startDAppHooksService(
      {required int delay, required bool showBGFetchAlert}) async {
    final isGranted = await PermissionUtils.initLocationPermission();

    if (isGranted) {
      await enableLocationService();

      if (state.locationServiceEnabled) {
        if (showBGFetchAlert) {
          await showBackgroundFetchAlertDialog(context: context!);
        }
        final success = await _dAppHooksUseCase.startDAppHooksService(delay);
        if (success) {
          showDAppHooksServiceSuccessSnackBar();
          return true;
        } else {
          showDAppHooksServiceFailureSnackBar();
          return false;
        }
      } else {
        return false;
      }
    } else {
      // Looks like the notification is blocked permanently
      showLocationPermissionBottomSheet(
          context: context!, openLocationSettings: openLocationSettings);
      return false;
    }
  }

  Future<bool> stopDAppHooksService({required bool showSnackbar}) async {
    await bgFetch.BackgroundFetch.stop(Config.dappHookTasks);
    if (showSnackbar) {
      showDAppHooksServiceDisableSuccessSnackBar();
    }
    return true;
  }

  void showDAppHooksServiceFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('dapp_hooks')!),
        type: SnackBarType.fail);
  }

  void showLocationServiceServiceFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('location')!),
        type: SnackBarType.fail);
  }

  void showDAppHooksServiceSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_launched_successfully')!
            .replaceAll('{0}', translate('dapp_hooks')!));
  }

  void showDAppHooksServiceDisableSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_disabled_successfully')!
            .replaceAll('{0}', translate('dapp_hooks')!));
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

  void showTimePickerDialog() async {
    final newTimeOfDay = await showTimePicker(
      context: context!,
      initialTime: state.dAppHooksData!.minerHooks.time,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (newTimeOfDay != null) {
      changeMinerHookTiming(newTimeOfDay);
    }
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    return super.dispose();
  }
}
