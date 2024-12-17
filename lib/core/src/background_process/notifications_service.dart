import 'package:background_fetch/background_fetch.dart';
import 'package:moonchain_wallet/app/logger.dart';
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
      print("isLoggedIn : $isLoggedIn, serviceEnabled : $serviceEnabled" );
      if (isLoggedIn && MXCChains.isMXCChains(chainId) && serviceEnabled) {
        await MoonchainWalletNotification()
            .setupFlutterNotifications(shouldInitFirebase: false);

        print('lowBalanceLimitEnabled: $lowBalanceLimitEnabled');
        if (lowBalanceLimitEnabled) {
          await backgroundFetchConfigUseCase.checkLowBalance(
              account!, lowBalanceLimit);
        }

        print('expectedTransactionFeeEnabled: $expectedTransactionFeeEnabled');
        if (expectedTransactionFeeEnabled) {
          await backgroundFetchConfigUseCase
              .checkTransactionFee(expectedTransactionFee);
        }

        print('expectedEpochOccurrenceEnabled: $expectedEpochOccurrenceEnabled');
        if (expectedEpochOccurrenceEnabled) {
          periodicalCallData =
              await backgroundFetchConfigUseCase.checkEpochOccur(
                  periodicalCallData,
                  lastEpoch,
                  expectedEpochOccurrence,
                  chainId);
        }

        print('activityReminderEnabled: $activityReminderEnabled');
        if (activityReminderEnabled) {
          await blueberryRingBackgroundNotificationsUseCase
              .checkActivityReminder();
        }

        print('sleepInsightEnabled: $sleepInsightEnabled');
        if (sleepInsightEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkSleepInsight();
        }

        print('heartAlertEnabled: $heartAlertEnabled');
        if (heartAlertEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkHeartAlert();
        }

        print('lowBatteryEnabled: $lowBatteryEnabled');
        if (lowBatteryEnabled) {
          await blueberryRingBackgroundNotificationsUseCase.checkLowBattery();
        }

        print('periodicalCallData: ${periodicalCallData.toString()}');
        backgroundFetchConfigUseCase.updateItem(periodicalCallData);
        BackgroundFetch.finish(taskId);
      } else {
        print("Terminating background service because conditions doesn't meet" );
        // terminate background fetch
        BackgroundFetch.stop(taskId);
      }
    } catch (e, s) {
      print("Background fetch ERROR : $e" );
      print("Background fetch stacktrace : $s" );
      BackgroundFetch.finish(taskId);
    }
  }
}
