import 'dart:async';
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

  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  final geo.GeolocatorPlatform _geoLocatorPlatform =
      geo.GeolocatorPlatform.instance;
  late StreamSubscription<geo.ServiceStatus> streamSubscription;

  @override
  void initState() {
    super.initState();

    listen(_dAppHooksUseCase.dappHooksData, (value) {
      checkDAppHooksDataChange(value);
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      notify(() => state.network = value);
    });

    initLocationServiceStateStream();
  }

  void initLocationServiceStateStream() async {
    Stream<geo.ServiceStatus> locationStateStream =
        _geoLocatorPlatform.getServiceStatusStream();

    streamSubscription = locationStateStream.listen((status) {
      checkWifiHookEnabled();
    });

    checkWifiHookEnabled();
  }

  Future<bool> enableLocationService() async {
    ServiceStatus locationServiceStatus =
        await Permission.location.serviceStatus;
    bool locationServiceEnabled = locationServiceStatus.isEnabled;
    if (!locationServiceEnabled) {
      try {
        await _geoLocatorPlatform.getCurrentPosition();
        return true;
      } catch (e) {
        showLocationServiceServiceFailureSnackBar();
        return false;
      }
    }
    return true;
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
    if (value) {
      checkWifiHooksRequirements();
    } else {
      updateWifiHooksEnabled(value);
    }
  }

  void updateWifiHooksEnabled(bool value) {
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
      time: state.dAppHooksData!.minerHooks.time
          .copyWith(hour: value.hour, minute: value.minute, second: 0),
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
  }

  // Checks if wifi hooks enabled, If enabled starts location service
  void checkWifiHookEnabled() {
    if (state.dAppHooksData!.wifiHooks.enabled &&
        state.dAppHooksData!.enabled) {
      checkWifiHooksRequirements();
    }
  }

  Future<void> checkWifiHooksRequirements() async {
    final isGranted = await PermissionUtils.initLocationPermission();

    if (isGranted) {
      final isServiceEnabled = await enableLocationService();
      if (isServiceEnabled) {
        _dAppHooksUseCase.setLocationSettings();
      }
      updateWifiHooksEnabled(isServiceEnabled);
    } else {
      updateWifiHooksEnabled(false);
      // Looks like the notification is blocked permanently
      showLocationPermissionBottomSheet(
          context: context!, openLocationSettings: openLocationSettings);
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
    final currentTimeOfDay = state.dAppHooksData!.minerHooks.time;
    final newTimeOfDay = await showTimePicker(
      context: context!,
      initialTime: TimeOfDay(
          hour: currentTimeOfDay.hour, minute: currentTimeOfDay.minute),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (newTimeOfDay != null) {
      changeMinerHookTiming(newTimeOfDay);
    }
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscription.cancel();
    return super.dispose();
  }
}
