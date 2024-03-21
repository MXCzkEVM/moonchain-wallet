import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../dapp_hooks_state.dart';
import '../domain/dapp_hooks_use_case.dart';
import '../widgets/background_fetch_dialog.dart';

class DAppHooksHelper {
  DAppHooksHelper(
      {required this.state,
      required this.dAppHooksUseCase,
      required this.backgroundFetchConfigUseCase,
      required this.context,
      required this.translate});

  DAppHooksUseCase dAppHooksUseCase;
  BackgroundFetchConfigUseCase backgroundFetchConfigUseCase;
  DAppHooksState state;
  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  BuildContext? context;
  String? Function(String) translate;

  static Future<void> shouldUpdateWrapper(
      Future<bool> Function() execution, void Function() update) async {
    final executionResult = await execution();
    if (executionResult) {
      update();
    }
  }

  void changeDAppHooksEnabled(bool value) async {
    shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await startDAppHooksService(
            delay: state.dAppHooksData!.duration, showBGFetchAlert: true);
      } else {
        update = await stopDAppHooksService(showSnackbar: true);
      }
      return update;
    }, () {
      return dAppHooksUseCase.updateDAppHooksEnabled(value);
    });
  }

  // delay is in minutes, returns true if success
  Future<bool> startDAppHooksService(
      {required int delay, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      final res =
          await showDAppHooksBackgroundFetchAlertDialog(context: context!);
      if (res == null || !res) {
        return false;
      }
    }
    final success = await dAppHooksUseCase.startDAppHooksService(delay);
    if (success) {
      dappHooksSnackBarUtils.showDAppHooksServiceSuccessSnackBar();
    } else {
      dappHooksSnackBarUtils.showDAppHooksServiceFailureSnackBar();
    }
    return success;
  }

  Future<bool> stopDAppHooksService({required bool showSnackbar}) async {
    final dappHooksData = dAppHooksUseCase.dappHooksData.value;
    final periodicalCallData =
        backgroundFetchConfigUseCase.periodicalCallData.value;
    final turnOffAll =
        AXSBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData);
    await dAppHooksUseCase.stopDAppHooksService(turnOffAll: turnOffAll);
    if (showSnackbar) {
      dappHooksSnackBarUtils.showDAppHooksServiceDisableSuccessSnackBar();
    }
    return true;
  }

  void handleFrequencyChange(PeriodicalCallDuration duration) {
    shouldUpdateWrapper(() async {
      late bool update;
      update = await startDAppHooksService(
          delay: duration.toMinutes(), showBGFetchAlert: false);
      return update;
    }, () {
      return dAppHooksUseCase.updateDAppHooksDuration(duration);
    });
  }
}
