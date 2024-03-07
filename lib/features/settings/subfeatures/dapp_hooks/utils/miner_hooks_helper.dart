import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:flutter/material.dart';

import '../dapp_hooks_state.dart';
import '../domain/dapp_hooks_use_case.dart';
import '../widgets/auto_claim_dialog.dart';
import '../widgets/background_fetch_dialog.dart';

class MinerHooksHelper {
  MinerHooksHelper(
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

  // delay is in minutes, returns true if success
  Future<bool> startMinerHooksService(
      {required DateTime time, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      await showBackgroundFetchAlertDialog(context: context!);
    }

    final success = await dAppHooksUseCase.scheduleAutoClaimTransaction(time);
    final reached = dAppHooksUseCase.isTimeReached(time);

    if (success) {
      // Time past, need to run the auto claim
      if (reached) {
        await showAutoClaimExecutionAlertDialog(
            context: context!,
            executeAutoClaim: () {
              dAppHooksUseCase.claimMiners(
                  account: state.account!,
                  minerAutoClaimTime: time,
                  selectedMinerListId:
                      state.dAppHooksData!.minerHooks.selectedMiners);
            });
      }
      dappHooksSnackBarUtils.showMinerHooksServiceSuccessSnackBar();
      return true;
    } else {
      dappHooksSnackBarUtils.showMinerHooksServiceFailureSnackBar();
      return false;
    }
  }

  Future<bool> stopAutoClaimService({required bool showSnackbar}) async {
    final dappHooksData = dAppHooksUseCase.dappHooksData.value;
    final periodicalCallData =
        backgroundFetchConfigUseCase.periodicalCallData.value;
    final turnOffAll =
        AXSBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData);

    await dAppHooksUseCase.stopMinerAutoClaimService(turnOffAll: turnOffAll);
    if (showSnackbar) {
      dappHooksSnackBarUtils.showMinerHooksServiceDisableSuccessSnackBar();
    }
    return true;
  }

  void changeMinerHooksEnabled(bool value) {
    DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await startMinerHooksService(
            time: state.dAppHooksData!.minerHooks.time, showBGFetchAlert: true);
      } else {
        update = await stopAutoClaimService(showSnackbar: true);
      }
      return update;
    }, () {
      return dAppHooksUseCase.updateMinerHooksEnabled(value);
    });
  }

  void changeMinerHookTiming(TimeOfDay value) async {
    DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      final currentDateTime = state.dAppHooksData!.minerHooks.time;
      final time = currentDateTime.copyWith(
          hour: value.hour, minute: value.minute, second: 0);
      update =
          await startMinerHooksService(time: time, showBGFetchAlert: false);
      return update;
    }, () {
      return dAppHooksUseCase.updateMinerHookTiming(value);
    });
  }
}
