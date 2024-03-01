import 'package:background_fetch/background_fetch.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DAppHooksService {

  static void dappHooksServiceCallBackDispatcherForeground(
      String taskId) async {
    try {
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final chainConfigurationUseCase =
          container.read(chainConfigurationUseCaseProvider);
      final accountUseCase = container.read(accountUseCaseProvider);
      // final backgroundFetchConfigUseCase =
      //     container.read(backgroundFetchConfigUseCaseProvider);
      final dAppHooksUseCase = container.read(dAppHooksUseCaseProvider);

      final selectedNetwork =
          chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
      DAppHooksModel dappHooksData = dAppHooksUseCase.dappHooksData.value;
      final chainId = selectedNetwork.chainId;

      final isLoggedIn = authUseCase.loggedIn;
      final account = accountUseCase.account.value;
      final serviceEnabled = dappHooksData.enabled;
      final wifiHooksEnabled = dappHooksData.wifiHooks.enabled;
      final minerHooksEnabled = dappHooksData.minerHooks.enabled;
      final minerHooksTime = dappHooksData.minerHooks.time;
      final selectedMiners = dappHooksData.minerHooks.selectedMiners;

      // Make sure user is logged in
      if (isLoggedIn && Config.isMxcChains(chainId) && serviceEnabled) {
        AXSNotification().setupFlutterNotifications(shouldInitFirebase: false);

        if (wifiHooksEnabled) {
          await dAppHooksUseCase.sendWifiInfo(
            account!,
          );
        }

        final now = DateTime.now();
        final isPast = !(now.difference(minerHooksTime).isNegative);

        // if (minerHooksEnabled && !isPast) {
        //   final updatedAutoClaimTime = await dAppHooksUseCase.claimMiners(
        //       account: account!,
        //       selectedMinerListId: selectedMiners,
        //       minerAutoClaimTime: minerHooksTime);
        //   dappHooksData = dappHooksData.copyWith(
        //       minerHooks: dappHooksData.minerHooks
        //           .copyWith(time: updatedAutoClaimTime));
        // }

        dAppHooksUseCase.updateItem(dappHooksData);
        BackgroundFetch.finish(taskId);
      } else {
        // terminate background fetch
        BackgroundFetch.stop(taskId);
      }
    } catch (e) {
      BackgroundFetch.finish(taskId);
    }
  }

  static void autoClaimServiceCallBackDispatcherForeground(
      String taskId) async {
    try {
      print('Hello');
      print(taskId);
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final chainConfigurationUseCase =
          container.read(chainConfigurationUseCaseProvider);
      final accountUseCase = container.read(accountUseCaseProvider);
      // final backgroundFetchConfigUseCase =
      //     container.read(backgroundFetchConfigUseCaseProvider);
      final dAppHooksUseCase = container.read(dAppHooksUseCaseProvider);

      final selectedNetwork =
          chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
      DAppHooksModel dappHooksData = dAppHooksUseCase.dappHooksData.value;
      final chainId = selectedNetwork.chainId;

      final isLoggedIn = authUseCase.loggedIn;
      final account = accountUseCase.account.value;
      // final serviceEnabled = dappHooksData.enabled;
      final minerHooksEnabled = dappHooksData.minerHooks.enabled;
      final minerHooksTime = dappHooksData.minerHooks.time;
      final selectedMiners = dappHooksData.minerHooks.selectedMiners;
      final now = DateTime.now();
      print(now);
      print(isLoggedIn && Config.isMxcChains(chainId) && minerHooksEnabled);
      print(now.difference(minerHooksTime).isNegative);
      // Make sure user is logged in
      if (isLoggedIn && Config.isMxcChains(chainId) && minerHooksEnabled) {
        AXSNotification().setupFlutterNotifications(shouldInitFirebase: false);

        final now = DateTime.now();
        final nowTime = TimeOfDay.fromDateTime(now);
        final claimTime = TimeOfDay.fromDateTime(minerHooksTime);

        final nowTimeInt = MXCType.timeOfDayInMinutes(nowTime);
        final claimTimeInt = MXCType.timeOfDayInMinutes(claimTime);

        print(now);
        print(now.difference(minerHooksTime).isNegative);
        final isPast = !(now.difference(minerHooksTime).isNegative);

        if (isPast) {
          // final updatedAutoClaimTime = await dAppHooksUseCase.claimMiners(
          //     account: account!,
          //     selectedMinerListId: selectedMiners,
          //     minerAutoClaimTime: minerHooksTime);
          // dappHooksData = dappHooksData.copyWith(
          //     minerHooks: dappHooksData.minerHooks
          //         .copyWith(time: updatedAutoClaimTime));
        }

        dAppHooksUseCase.updateItem(dappHooksData);
        BackgroundFetch.finish(taskId);
      } else {
        // terminate background fetch
        BackgroundFetch.stop(taskId);
      }
    } catch (e) {
      BackgroundFetch.finish(taskId);
    }
  }
}
