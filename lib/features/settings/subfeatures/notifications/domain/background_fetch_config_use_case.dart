import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/contract/token_contract_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;

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
      if (network != null && !Config.isMxcChains(network.chainId)) {
        bgFetch.BackgroundFetch.stop(Config.axsPeriodicalTask);
      }
      // else if (network != null && Config.isMxcChains(network.chainId)) {
      //   isBGFetchEnabled(_repository.item) {

      //   }
      // }
    });
  }

  Future<void> checkLowBalance(Account account, double lowBalanceLimit) async {
    print("lowBalanceLimitEnabled");
    final balance = await _tokenContractUseCase.getEthBalance(account.address);
    final balanceDouble = balance.getInEther.toDouble();
    print("lowBalanceLimitEnabled $balanceDouble $lowBalanceLimit");
    if (balanceDouble < lowBalanceLimit) {
      AXSNotification().showNotification('Time to top up!',
          'Your balance is currently $balanceDouble MXC, Below expected $lowBalanceLimit. MXC');
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
          'Transaction fee below expected price!',
          'Transaction fee is currently $transactionFee MXC, Lower than $expectedTransactionFee MXC.');
    }
  }

  Future<PeriodicalCallData> checkEpochOccur(
      PeriodicalCallData periodicalCallData,
      int lastEpoch,
      int expectedEpochOccurrence) async {
    print('expectedEpochOccurrenceEnabled');

    final epochNumber = await _tokenContractUseCase.getEpochDetails();
    print(
        "expectedEpochOccurrenceEnabled $lastEpoch $epochNumber $expectedEpochOccurrence");
    if (lastEpoch == 0) {
      periodicalCallData = periodicalCallData.copyWith(lasEpoch: epochNumber);
      return periodicalCallData;
    }

    int epochQuantity = epochNumber - lastEpoch;

    if (expectedEpochOccurrence == epochQuantity) {
      periodicalCallData = periodicalCallData.copyWith(lasEpoch: epochNumber);
      AXSNotification().showNotification('Expected epoch just happened!',
          'The epoch that you were waiting for is now reached.');
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
}
