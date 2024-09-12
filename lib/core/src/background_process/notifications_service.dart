import 'package:background_fetch/background_fetch.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';

class NotificationsService {
// Foreground
  static void notificationsCallbackDispatcher(String taskId) async {
    try {
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final chainConfigurationUseCase =
          container.read(chainConfigurationUseCaseProvider);
      final accountUseCase = container.read(accountUseCaseProvider);
      final backgroundFetchConfigUseCase =
          container.read(backgroundFetchConfigUseCaseProvider);
      final blueberryRingBackgroundNotificationsUseCase =
          container.read(blueberryRingBackgroundNotificationsUseCaseProvider);
      final contextLessTranslationUseCase =
          container.read(contextLessTranslationUseCaseProvider);

      final selectedNetwork =
          chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
      PeriodicalCallData periodicalCallData =
          backgroundFetchConfigUseCase.periodicalCallData.value;
      final chainId = selectedNetwork.chainId;

      final isLoggedIn = authUseCase.loggedIn;
      final account = accountUseCase.account.value;
      final lowBalanceLimit = periodicalCallData.lowBalanceLimit;
      final expectedTransactionFee = periodicalCallData.expectedTransactionFee;
      final lowBalanceLimitEnabled = periodicalCallData.lowBalanceLimitEnabled;
      final expectedTransactionFeeEnabled =
          periodicalCallData.expectedTransactionFeeEnabled;
      final lastEpoch = periodicalCallData.lasEpoch;
      final expectedEpochOccurrence =
          periodicalCallData.expectedEpochOccurrence;
      final expectedEpochOccurrenceEnabled =
          periodicalCallData.expectedEpochOccurrenceEnabled;
      final serviceEnabled = periodicalCallData.serviceEnabled;

      final activityReminderEnabled =
          periodicalCallData.activityReminderEnabled;
      final sleepInsightEnabled = periodicalCallData.sleepInsightEnabled;
      final heartAlertEnabled = periodicalCallData.heartAlertEnabled;
      final lowBatteryEnabled = periodicalCallData.lowBatteryEnabled;

      // Make sure user is logged in
      if (isLoggedIn && MXCChains.isMXCChains(chainId) && serviceEnabled) {
        await MoonchainWalletNotification()
            .setupFlutterNotifications(shouldInitFirebase: false);

        if (lowBalanceLimitEnabled) {
          await backgroundFetchConfigUseCase.checkLowBalance(
              account!, lowBalanceLimit);
        }

        if (expectedTransactionFeeEnabled) {
          await backgroundFetchConfigUseCase
              .checkTransactionFee(expectedTransactionFee);
        }

        if (expectedEpochOccurrenceEnabled) {
          periodicalCallData =
              await backgroundFetchConfigUseCase.checkEpochOccur(
                  periodicalCallData,
                  lastEpoch,
                  expectedEpochOccurrence,
                  chainId);
        }

        if (activityReminderEnabled) {
          await blueberryRingBackgroundNotificationsUseCase
              .checkActivityReminder();
        }

        if (sleepInsightEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkSleepInsight();
        }

        if (heartAlertEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkHeartAlert();
        }

        if (lowBatteryEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkLowBattery();
        }

        backgroundFetchConfigUseCase.updateItem(periodicalCallData);
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
