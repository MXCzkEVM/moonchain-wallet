import 'package:background_fetch/background_fetch.dart';
import 'package:moonchain_wallet/core/core.dart';
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
      final dAppHooksUseCase = container.read(dAppHooksUseCaseProvider);
      final contextLessTranslationUseCase =
          container.read(contextLessTranslationUseCaseProvider);

      final selectedNetwork =
          chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
      DAppHooksModel dappHooksData = dAppHooksUseCase.dappHooksData.value;
      final chainId = selectedNetwork.chainId;

      final isLoggedIn = authUseCase.loggedIn;
      final account = accountUseCase.account.value;
      final wifiHooksEnabled = dappHooksData.wifiHooks.enabled;

      // Make sure user is logged in
      if (isLoggedIn && MXCChains.isMXCChains(chainId) && wifiHooksEnabled) {
        await MoonchainWalletNotification()
            .setupFlutterNotifications(shouldInitFirebase: false);

        await dAppHooksUseCase.sendWifiInfo(
          account!,
        );

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
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final chainConfigurationUseCase =
          container.read(chainConfigurationUseCaseProvider);
      final accountUseCase = container.read(accountUseCaseProvider);
      final dAppHooksUseCase = container.read(dAppHooksUseCaseProvider);
      final contextLessTranslationUseCase =
          container.read(contextLessTranslationUseCaseProvider);

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
      // Make sure user is logged in
      if (isLoggedIn && MXCChains.isMXCChains(chainId) && minerHooksEnabled) {
        await MoonchainWalletNotification()
            .setupFlutterNotifications(shouldInitFirebase: false);

        await dAppHooksUseCase.executeMinerAutoClaim(
            account: account!,
            selectedMinerListId: selectedMiners,
            minerAutoClaimTime: minerHooksTime);
        BackgroundFetch.finish(taskId);
      } else {
        // terminate background fetch
        BackgroundFetch.stop(taskId);
      }
    } catch (e) {
      BackgroundFetch.finish(taskId);
    }
  }

  static void blueberryAutoSyncServiceCallBackDispatcherForeground(
      String taskId) async {
    try {
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final chainConfigurationUseCase =
          container.read(chainConfigurationUseCaseProvider);
      final accountUseCase = container.read(accountUseCaseProvider);
      final dAppHooksUseCase = container.read(dAppHooksUseCaseProvider);
      final contextLessTranslationUseCase =
          container.read(contextLessTranslationUseCaseProvider);

      final selectedNetwork =
          chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
      DAppHooksModel dappHooksData = dAppHooksUseCase.dappHooksData.value;
      final chainId = selectedNetwork.chainId;

      final isLoggedIn = authUseCase.loggedIn;
      final account = accountUseCase.account.value;
      // final serviceEnabled = dappHooksData.enabled;
      final autoSyncEnabled = dappHooksData.blueberryRingHooks.enabled;
      final ringHooksTime = dappHooksData.blueberryRingHooks.time;
      final selectedRings = dappHooksData.blueberryRingHooks.selectedRings;
      // Make sure user is logged in
      if (isLoggedIn && MXCChains.isMXCChains(chainId) && autoSyncEnabled) {
        await MoonchainWalletNotification()
            .setupFlutterNotifications(shouldInitFirebase: false);

        await dAppHooksUseCase.syncBlueberryRingSync(
            account: account!,
            selectedRingsListId: selectedRings,
            ringAutoSyncTime: ringHooksTime);
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
