import 'dart:io';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/contract/token_contract_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;

import '../../../../../main.dart';
import 'background_fetch_config_repository.dart';

class BackgroundFetchConfigUseCase extends ReactiveUseCase {
  BackgroundFetchConfigUseCase(
    this._repository,
    this._chainConfigurationUseCase,
    this._tokenContractUseCase,
  ) {
    initialize();
  }

  final BackgroundFetchConfigRepository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final TokenContractUseCase _tokenContractUseCase;

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
          network != null && !Config.isMxcChains(network.chainId);
      final periodicalCallData = _repository.item;
      if (!isMXCChains) {
        bgFetch.BackgroundFetch.stop(Config.axsPeriodicalTask);
      } else if (isMXCChains && periodicalCallData.serviceEnabled) {
        startBGFetch(periodicalCallData.duration);
      }
    });
  }

  Future<void> checkLowBalance(Account account, double lowBalanceLimit) async {
    print("lowBalanceLimitEnabled");
    final balance = await _tokenContractUseCase.getEthBalance(account.address);
    final balanceDouble = balance.getInEther.toDouble();
    print("lowBalanceLimitEnabled $balanceDouble $lowBalanceLimit");
    if (balanceDouble < lowBalanceLimit) {
      AXSNotification().showNotification(
        "Time to Top-up!",
        "Heads up! Your balance is now at {0} MXC, which is below the minimum threshold of {1} MXC. A top-up might be a good idea to maintain seamless transactions."
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
      AXSNotification().showNotification(
        "Time to do the transaction!",
        "Great news! The current transaction fee is just {0} MXC, which is lower than the usual {1} MXC. It's an opportune moment to make your transactions more cost-effective."
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
      AXSNotification().showNotification("Epoch Achievement Alert!",
          "Congratulations! The anticipated epoch you've been waiting for has just occurred. It's a significant milestone. Let's take the next steps forward.,");
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
  Future<bool> startBGFetch(int delay) async {
    try {
      // Stop If any is running
      await stopBGFetch();

      final configurationState = await bgFetch.BackgroundFetch.configure(
          bgFetch.BackgroundFetchConfig(
              minimumFetchInterval: delay,
              stopOnTerminate: false,
              enableHeadless: true,
              startOnBoot: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: bgFetch.NetworkType.ANY),
          callbackDispatcherForeGround);
      // Android Only
      final backgroundFetchState =
          await bgFetch.BackgroundFetch.registerHeadlessTask(
              callbackDispatcher);

      final scheduleState =
          await bgFetch.BackgroundFetch.scheduleTask(bgFetch.TaskConfig(
        taskId: Config.axsPeriodicalTask,
        delay: delay * 60 * 1000,
        periodic: true,
        requiresNetworkConnectivity: true,
        startOnBoot: true,
        stopOnTerminate: false,
        requiredNetworkType: bgFetch.NetworkType.ANY,
      ));

      if (scheduleState &&
              configurationState == bgFetch.BackgroundFetch.STATUS_AVAILABLE ||
          configurationState == bgFetch.BackgroundFetch.STATUS_RESTRICTED &&
              (Platform.isAndroid ? backgroundFetchState : true)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<int> stopBGFetch() async {
    return await bgFetch.BackgroundFetch.stop(Config.axsPeriodicalTask);
  }
}
