import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;

import 'background_fetch_config_repository.dart';

class BackgroundFetchConfigUseCase extends ReactiveUseCase {
  BackgroundFetchConfigUseCase(
      this._repository,
      this._chainConfigurationUseCase,
      this._tokenContractUseCase,
      this._contextLessTranslationUseCase) {
    initialize();
  }

  String get taskId => BackgroundExecutionConfig.notificationsTask;

  final BackgroundFetchConfigRepository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final TokenContractUseCase _tokenContractUseCase;
  final ContextLessTranslationUseCase _contextLessTranslationUseCase;

  // Context less translation, This should be only used for BG functions
  String cTranslate(String key) =>
      _contextLessTranslationUseCase.translate(key);

  late final ValueStream<PeriodicalCallData> periodicalCallData =
      reactiveField(_repository.periodicalCallData);

  void updateItem(PeriodicalCallData item) {
    _repository.updateItem(item);
    update(periodicalCallData, _repository.item);
  }

  void removeItem(PeriodicalCallData item) {
    _repository.removeItem(item);
    update(periodicalCallData, _repository.item);
  }

  void initialize() {
    _chainConfigurationUseCase.selectedNetwork.listen((network) {
      final isMXCChains =
          network != null && !MXCChains.isMXCChains(network.chainId);
      final periodicalCallData = _repository.item;
      if (!isMXCChains) {
        bgFetch.BackgroundFetch.stop(
            BackgroundExecutionConfig.notificationsTask);
      } else if (isMXCChains && periodicalCallData.serviceEnabled) {
        startNotificationsService(periodicalCallData.duration);
      }
    });
  }

  void updateActivityReminderEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(activityReminderEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateSleepInsightEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(sleepInsightEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateHeartAlertEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(heartAlertEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateLowBatteryEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(lowBatteryEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateNotificationsServiceEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(serviceEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateLowBalanceLimitEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(lowBalanceLimitEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateExpectedTransactionFeeEnabled(bool value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(expectedTransactionFeeEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateExpectedEpochQuantityEnabled(bool value) {
    final updatedPeriodicalCallData = periodicalCallData.value
        .copyWith(expectedEpochOccurrenceEnabled: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateEpochOccur(int value) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(expectedEpochOccurrence: value);
    updateItem(updatedPeriodicalCallData);
  }

  void updateNotificationsServiceFrequency(PeriodicalCallDuration duration) {
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(duration: duration.toMinutes());
    updateItem(updatedPeriodicalCallData);
  }

  void updateLowBalance(String lowBalanceString) {
    final lowBalance = double.parse(lowBalanceString);
    final updatedPeriodicalCallData =
        periodicalCallData.value.copyWith(lowBalanceLimit: lowBalance);
    updateItem(updatedPeriodicalCallData);
  }

  void updateExpectedTransactionFee(String expectedTransactionFeeString) {
    final expectedTransactionFee = double.parse(expectedTransactionFeeString);
    final updatedPeriodicalCallData = periodicalCallData.value
        .copyWith(expectedTransactionFee: expectedTransactionFee);
    updateItem(updatedPeriodicalCallData);
  }

  Future<void> checkLowBalance(Account account, double lowBalanceLimit) async {
    print("lowBalanceLimitEnabled");
    final balance = await _tokenContractUseCase.getEthBalance(account.address);
    final balanceDouble = balance.getInEther.toDouble();
    print("lowBalanceLimitEnabled $balanceDouble $lowBalanceLimit");
    if (balanceDouble < lowBalanceLimit) {
      MoonchainWalletNotification().showNotification(
        cTranslate('low_balance_notification_title'),
        cTranslate('low_balance_notification_text')
            .replaceFirst('{0}', balanceDouble.toString())
            .replaceFirst('{1}', lowBalanceLimit.toString()),
      );
    }
  }

  Future<void> checkTransactionFee(double expectedTransactionFee) async {
    print("expectedTransactionFeeEnabled");

    final gasPrice = await _tokenContractUseCase.getGasPrice();
    final gasPriceDoubleWei = gasPrice.getInWei.toDouble();
    final transactionFeeWei = gasPriceDoubleWei * Config.minerDAppGasLimit;
    final transactionFee =
        MxcAmount.fromDoubleByWei(transactionFeeWei).getInEther.toDouble();

    print(
        "expectedTransactionFeeEnabled $transactionFee $expectedTransactionFee");
    if (transactionFee < expectedTransactionFee) {
      MoonchainWalletNotification().showNotification(
        cTranslate('tx_fee_reached_expectation_notification_title'),
        cTranslate('tx_fee_reached_expectation_notification_text')
            .replaceFirst('{0}', transactionFee.toString())
            .replaceFirst('{1}', expectedTransactionFee.toString()),
      );
    }
  }

  Future<PeriodicalCallData> checkEpochOccur(
    PeriodicalCallData periodicalCallData,
    int lastEpoch,
    int expectedEpochOccurrence,
    int chainId,
  ) async {
    print('expectedEpochOccurrenceEnabled');

    final epochNumber = await _tokenContractUseCase.getEpochDetails(chainId);
    print(
        "expectedEpochOccurrenceEnabled $lastEpoch $epochNumber $expectedEpochOccurrence");
    if (lastEpoch == 0) {
      periodicalCallData = periodicalCallData.copyWith(lasEpoch: epochNumber);
      return periodicalCallData;
    }

    int epochQuantity = epochNumber - lastEpoch;

    if (expectedEpochOccurrence <= epochQuantity) {
      periodicalCallData = periodicalCallData.copyWith(lasEpoch: epochNumber);
      MoonchainWalletNotification().showNotification(
          cTranslate('epoch_occur_notification_title'),
          cTranslate('epoch_occur_notification_text'));
    }

    return periodicalCallData;
  }

  // Detect If change was about service enable status not amount change because amount changes won't effect the service & will be loaded from DB.
  bool isServicesEnabledStatusChanged(PeriodicalCallData newPeriodicalCallData,
      PeriodicalCallData periodicalCallData) {
    return newPeriodicalCallData.expectedTransactionFeeEnabled !=
            periodicalCallData.expectedTransactionFeeEnabled ||
        newPeriodicalCallData.lowBalanceLimitEnabled !=
            periodicalCallData.lowBalanceLimitEnabled ||
        newPeriodicalCallData.expectedEpochOccurrenceEnabled !=
            periodicalCallData.expectedEpochOccurrenceEnabled;
  }

  // There is a chance where user disables any service so in this case we don't want to run BG fetch service init again.
  bool hasAnyServiceBeenEnabled(PeriodicalCallData newPeriodicalCallData,
      PeriodicalCallData periodicalCallData) {
    return (newPeriodicalCallData.expectedTransactionFeeEnabled == true &&
            periodicalCallData.expectedTransactionFeeEnabled == false) &&
        (newPeriodicalCallData.lowBalanceLimitEnabled == true &&
            periodicalCallData.lowBalanceLimitEnabled == false) &&
        (newPeriodicalCallData.expectedEpochOccurrenceEnabled == true &&
            periodicalCallData.expectedEpochOccurrenceEnabled == false);
  }

  bool hasDurationChanged(PeriodicalCallData newPeriodicalCallData,
      PeriodicalCallData periodicalCallData) {
    return newPeriodicalCallData.duration != periodicalCallData.duration;
  }

  // Check wether BG fetch is enabled in any of options
  bool isBGFetchEnabled(PeriodicalCallData periodicalCallData) =>
      periodicalCallData.expectedTransactionFeeEnabled ||
      periodicalCallData.expectedEpochOccurrenceEnabled ||
      periodicalCallData.lowBalanceLimitEnabled;

  // delay is in minutes
  Future<bool> startNotificationsService(
    int delay,
  ) async {
    try {
      final result =
          await MXCWalletBackgroundFetch.startBackgroundProcess(taskId: taskId);

      if (!result) return result;

      final scheduleState =
          await bgFetch.BackgroundFetch.scheduleTask(bgFetch.TaskConfig(
        taskId: taskId,
        delay: delay * 60 * 1000,
        periodic: true,
        requiresNetworkConnectivity: true,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: false,
        requiredNetworkType: bgFetch.NetworkType.ANY,
      ));

      return scheduleState;
    } catch (e) {
      return false;
    }
  }

  Future<int> stopNotificationsService({required bool turnOffAll}) async {
    return await MXCWalletBackgroundFetch.stopServices(
        taskId: taskId, turnOffAll: turnOffAll);
  }
}
