import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/widgets/background_fetch_dialog.dart';
import 'package:flutter/material.dart';
import '../domain/dapp_hooks_use_case.dart';

class BlueberryHooksHelper {
  BlueberryHooksHelper(
      {required this.accountUseCase,
      required this.dAppHooksUseCase,
      required this.backgroundFetchConfigUseCase,
      required this.context,
      required this.translate});

  DAppHooksUseCase dAppHooksUseCase;
  BackgroundFetchConfigUseCase backgroundFetchConfigUseCase;
  AccountUseCase accountUseCase;
  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  BuildContext? context;
  String? Function(String) translate;

  // delay is in minutes, returns true if success
  Future<bool> startBlueberryRingHooksService(
      {required DateTime time, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      final res = await showBackgroundFetchAlertDialog(context: context!);
      if (res == null || !res) {
        return false;
      }
    }

    // Check Bluetooth & nearby devices enabled
    // After all enabled start service
    // listen for state and stop If the bluetooth & nearby device is went off
    // The Service will listen to the ad data and do the things on that
    final success =
        await dAppHooksUseCase.scheduleBlueberryAutoSyncTransaction(time);

    if (success) {
      // Time past, need to run the auto claim

      dappHooksSnackBarUtils.showBlueberryRingHooksServiceSuccessSnackBar();

      return true;
    } else {
      dappHooksSnackBarUtils.showBlueberryRingHooksServiceFailureSnackBar();
      return false;
    }
  }

  Future<bool> stopBlueberryRingService({required bool showSnackbar}) async {
    final dappHooksData = dAppHooksUseCase.dappHooksData.value;
    final periodicalCallData =
        backgroundFetchConfigUseCase.periodicalCallData.value;
    final turnOffAll =
        MXCWalletBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData);

    await dAppHooksUseCase.stopBlueberryAutoSyncService(turnOffAll: turnOffAll);
    if (showSnackbar) {
      dappHooksSnackBarUtils.showBlueberryRingHooksServiceFailureSnackBar();
    }
    return true;
  }

  Future<void> changeBLueberryRingHooksEnabled(
    bool value,
  ) {
    return DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await startBlueberryRingHooksService(
            time: dAppHooksUseCase.dappHooksData.value.blueberryRingHooks.time,
            showBGFetchAlert: true);
      } else {
        update = await stopBlueberryRingService(showSnackbar: true);
      }
      return update;
    }, () {
      return dAppHooksUseCase.updateBlueberryRingHooksEnabled(value);
    });
  }

  Future<void> changeBlueberryRingHookTiming(TimeOfDay value) async {
    return DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      final currentDateTime =
          dAppHooksUseCase.dappHooksData.value.blueberryRingHooks.time;
      final time = currentDateTime.copyWith(
          hour: value.hour, minute: value.minute, second: 0);
      update = await startBlueberryRingHooksService(
          time: time, showBGFetchAlert: false);
      return update;
    }, () {
      return dAppHooksUseCase.updateBlueberryRingHookTiming(value);
    });
  }
}
