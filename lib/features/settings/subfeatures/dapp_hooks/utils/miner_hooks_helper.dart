import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/widgets/background_fetch_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/dapp_hooks_use_case.dart';
import '../widgets/auto_claim_dialog.dart';

class MinerHooksHelper {
  MinerHooksHelper(
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
  Future<bool> startMinerHooksService(
      {required DateTime time, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      final res = await showBackgroundFetchAlertDialog(context: context!);
      if (res == null || !res) {
        return false;
      }
    }

    final success = await dAppHooksUseCase.scheduleAutoClaimTransaction(time);
    final reached = dAppHooksUseCase.isTimeReached(time);

    bool shouldShowScheduleSnackBar = false;

    if (success) {
      // Time past, need to run the auto claim
      if (reached) {
        shouldShowScheduleSnackBar = !(await showAutoClaimExecutionAlertDialog(
                context: context!,
                executeAutoClaim: () {
                  dAppHooksUseCase.claimMiners(
                      account: accountUseCase.account.value!,
                      minerAutoClaimTime: time,
                      selectedMinerListId: dAppHooksUseCase
                          .dappHooksData.value.minerHooks.selectedMiners);
                }) ??
            false);
      }
      if (shouldShowScheduleSnackBar) {
        dappHooksSnackBarUtils
            .showScheduleSnackBar(DateFormat('HH:mm').format(time));
      } else {
        dappHooksSnackBarUtils.showMinerHooksServiceSuccessSnackBar();
      }
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
        MXCWalletBackgroundFetch.turnOffAll(dappHooksData, periodicalCallData);

    await dAppHooksUseCase.stopMinerAutoClaimService(turnOffAll: turnOffAll);
    if (showSnackbar) {
      dappHooksSnackBarUtils.showMinerHooksServiceDisableSuccessSnackBar();
    }
    return true;
  }

  Future<void> changeMinerHooksEnabled(
    bool value,
  ) {
    return DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      if (value) {
        update = await startMinerHooksService(
            time: dAppHooksUseCase.dappHooksData.value.minerHooks.time,
            showBGFetchAlert: true);
      } else {
        update = await stopAutoClaimService(showSnackbar: true);
      }
      return update;
    }, () {
      return dAppHooksUseCase.updateMinerHooksEnabled(value);
    });
  }

  Future<void> changeMinerHookTiming(TimeOfDay value) async {
    return DAppHooksHelper.shouldUpdateWrapper(() async {
      late bool update;
      final currentDateTime =
          dAppHooksUseCase.dappHooksData.value.minerHooks.time;
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
