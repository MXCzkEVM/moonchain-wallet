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
    if (taskId == BackgroundExecutionConfig.axsPeriodicalTask) {
      NotificationsService.notificationsCallbackDispatcher(taskId);
    } else if (taskId == BackgroundExecutionConfig.dappHookTasks) {
      DAppHooksService.dappHooksServiceCallBackDispatcherForeground(taskId);
    } else if (taskId == BackgroundExecutionConfig.minerAutoClaimTask) {
      DAppHooksService.autoClaimServiceCallBackDispatcherForeground(taskId);
    } else {
      bgFetch.BackgroundFetch.finish(taskId);
    }
  }

  // This function is
  static Future<void> stopBackgroundFetch() async {
    await bgFetch.BackgroundFetch.stop('flutter_background_fetch');
  }

  static bool turnOffAll(
      DAppHooksModel dAppHooksData, PeriodicalCallData periodicalCallData) {
    return !dAppHooksData.enabled &&
        !periodicalCallData.serviceEnabled &&
        !dAppHooksData.minerHooks.enabled;
  }

  static Future<int> stopServices(
      {required String taskId, required bool turnOffAll}) async {
    // It means turn off all, No services are alive
    if (turnOffAll) {
      return await bgFetch.BackgroundFetch.stop();
    }
    return await bgFetch.BackgroundFetch.stop(taskId);
  }

  static void bgFetchStatus() async {
    final status = await bgFetch.BackgroundFetch.status;
    print(status);
  }

  static Future<bool> startBackgroundProcess({required String taskId}) async {
    await stopServices(taskId: taskId, turnOffAll: false);
    return await _configureBackgroundProcess();
  }

  static Future<bool> _configureBackgroundProcess() async {
    final configurationState = await bgFetch.BackgroundFetch.configure(
        bgFetch.BackgroundFetchConfig(
            minimumFetchInterval:
                BackgroundExecutionConfig.axsBackgroundServiceInterval,
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
      return true;
    } else {
      return false;
    }
  }
}
