import 'dart:io';
// import 'package:moonchain_wallet';
import 'package:app_settings/app_settings.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/domain/dapp_hooks_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../widgets/widgets.dart';
import 'helpers.dart';

class NotificationsHelper {
  NotificationsHelper({
    required this.state,
    required this.backgroundFetchConfigUseCase,
    required this.bluetoothUseCase,
    required this.dAppHooksUseCase,
    required this.context,
    required this.translate,
    required this.notify,
  });

  DAppHooksUseCase dAppHooksUseCase;
  BackgroundFetchConfigUseCase backgroundFetchConfigUseCase;
  BluetoothUseCase bluetoothUseCase;
  NotificationsState state;
  NotificationsHooksSnackBarUtils get notificationsSnackBarUtils =>
      NotificationsHooksSnackBarUtils(translate: translate, context: context);
  BuildContext? context;
  String? Function(String) translate;
  void Function([void Function()? fun]) notify;

  static shouldUpdateWrapper(
      Future<bool> Function() execution, void Function() update) async {
    final executionResult = await execution();
    if (executionResult) {
      update();
    }
  }

  void changeNotificationsServiceEnabled(bool value) {
    shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await startNotificationsService(
            delay: state.periodicalCallData!.duration, showBGFetchAlert: true);
      } else {
        update = await stopNotificationsService(showSnackbar: true);
      }
      return update;
    }, () {
      return backgroundFetchConfigUseCase
          .updateNotificationsServiceEnabled(value);
    });
  }

  void checkBlueberryNotificationsRequirements(Function func) async {
    await bluetoothUseCase.turnOnBluetooth();

    final bluetoothTurnedOn = await bluetoothUseCase.isBluetoothTurnedOn();

    if (bluetoothTurnedOn) {
      func();
    }
  }

  void changeActivityReminderEnabled(bool value) => value
      ? checkBlueberryNotificationsRequirements(() =>
          backgroundFetchConfigUseCase.updateActivityReminderEnabled(value))
      : backgroundFetchConfigUseCase.updateActivityReminderEnabled(value);

  void changeSleepInsightEnabled(bool value) => value
      ? checkBlueberryNotificationsRequirements(
          () => backgroundFetchConfigUseCase.updateSleepInsightEnabled(value))
      : backgroundFetchConfigUseCase.updateSleepInsightEnabled(value);

  void changeHeartAlertEnabled(bool value) => value
      ? checkBlueberryNotificationsRequirements(
          () => backgroundFetchConfigUseCase.updateHeartAlertEnabled(value))
      : backgroundFetchConfigUseCase.updateHeartAlertEnabled(value);

  void changeLowBatteryEnabled(bool value) => value
      ? checkBlueberryNotificationsRequirements(
          () => backgroundFetchConfigUseCase.updateLowBatteryEnabled(value))
      : backgroundFetchConfigUseCase.updateLowBatteryEnabled(value);

  void changeLowBalanceLimitEnabled(bool value) =>
      backgroundFetchConfigUseCase.updateLowBalanceLimitEnabled(value);

  void changeExpectedTransactionFeeEnabled(bool value) =>
      backgroundFetchConfigUseCase.updateExpectedTransactionFeeEnabled(value);

  void changeExpectedEpochQuantityEnabled(bool value) =>
      backgroundFetchConfigUseCase.updateExpectedEpochQuantityEnabled(value);

  void updateEpochOccur(int value) =>
      backgroundFetchConfigUseCase.updateEpochOccur(value);

  // delay is in minutes
  Future<bool> startNotificationsService(
      {required int delay, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      final res = await showBackgroundFetchAlertDialog(context: context!);
      if (res == null || !res) {
        return false;
      }
    }
    final success =
        await backgroundFetchConfigUseCase.startNotificationsService(delay);
    if (success) {
      notificationsSnackBarUtils.showBGFetchSuccessSnackBar();
    } else {
      notificationsSnackBarUtils.showBGFetchFailureSnackBar();
    }
    return success;
  }

  Future<bool> stopNotificationsService({required bool showSnackbar}) async {
    final dappHooksData = dAppHooksUseCase.dappHooksData.value;
    final periodicalCallData = state.periodicalCallData;
    final turnOffAll =
        MXCWalletBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData!);
    await backgroundFetchConfigUseCase.stopNotificationsService(
        turnOffAll: turnOffAll);
    if (showSnackbar) {
      notificationsSnackBarUtils.showBGNotificationsDisableSuccessSnackBar();
    }
    return true;
  }

  void handleFrequencyChange(PeriodicalCallDuration duration) {
    shouldUpdateWrapper(() async {
      late bool update;
      update = await startNotificationsService(
          delay: duration.toMinutes(), showBGFetchAlert: false);
      return update;
    }, () {
      return backgroundFetchConfigUseCase
          .updateNotificationsServiceFrequency(duration);
    });
  }

  void checkNotificationsStatus() async {
    final isGranted = await PermissionUtils.checkNotificationPermission();
    if (state.isNotificationsEnabled == false && isGranted == true) {
      await MoonchainWalletFireBase.initializeFirebase();
      MoonchainWalletFireBase.initLocalNotificationsAndListeners();
    }
    notify(() => state.isNotificationsEnabled = isGranted);
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
      // notify(() => state.isNotificationsEnabled = isGranted);
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
}
