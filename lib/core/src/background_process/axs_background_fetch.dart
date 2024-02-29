import 'dart:io';

import 'package:background_fetch/background_fetch.dart' as bgFetch;
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AXSBackgroundFetch {
  @pragma(
      'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
  static void handleHeadlessCallBackDispatcher(
      bgFetch.HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] Headless task timed-out: $taskId");
      bgFetch.BackgroundFetch.finish(taskId);
      return;
    }
    handleCallBackDispatcher(task.taskId);
  }

  static void handleCallBackDispatcher(String taskId) async {
    if (taskId == Config.axsPeriodicalTask) {
      NotificationsService.notificationsCallbackDispatcher(taskId);
    } else if (taskId == Config.dappHookTasks) {
      DAppHooksService.dappHooksServiceCallBackDispatcherForeground(taskId);
    } else if (taskId == Config.minerAutoClaimTask) {
      DAppHooksService.autoClaimServiceCallBackDispatcherForeground(taskId);
    }
  }

  static void stopBackgroundFetch(DAppHooksModel dappHooksData,
      PeriodicalCallData periodicalCallData) async {
    // Stop only if both services are not running
    if (!dappHooksData.enabled && !periodicalCallData.serviceEnabled) {
      bgFetch.BackgroundFetch.stop('flutter_background_fetch');
    }
  }

  static void bgFetchStatus() async {
    final status = await bgFetch.BackgroundFetch.status;
    print(status);
  }

  static Future<bool> configureBackgroundProcess() async {
    bgFetchStatus();
    final configurationState = await bgFetch.BackgroundFetch.configure(
        bgFetch.BackgroundFetchConfig(
            minimumFetchInterval: Config.axsBackgroundServiceInterval,
            forceAlarmManager: true,
            stopOnTerminate: false,
            enableHeadless: true,
            startOnBoot: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: bgFetch.NetworkType.ANY),
        handleCallBackDispatcher);
    // Android Only
    final backgroundFetchState =
        await bgFetch.BackgroundFetch.registerHeadlessTask(
            handleHeadlessCallBackDispatcher);

    if (configurationState == bgFetch.BackgroundFetch.STATUS_AVAILABLE ||
        configurationState == bgFetch.BackgroundFetch.STATUS_RESTRICTED &&
            (Platform.isAndroid ? backgroundFetchState : true)) {
      bgFetchStatus();
      return true;
    } else {
      return false;
    }
  }
}
