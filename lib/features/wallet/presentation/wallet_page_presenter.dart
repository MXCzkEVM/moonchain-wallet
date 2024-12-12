import 'dart:typed_data';
import 'package:moonchain_wallet/common/components/recent_transactions/widgets/widgets.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/wallet/wallet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:mxc_logic/mxc_logic.dart';

import 'wallet_page_state.dart';

final walletContainer =
    PresenterContainer<WalletPresenter, WalletState>(() => WalletPresenter());

class WalletPresenter extends CompletePresenter<WalletState> {
  WalletPresenter() : super(WalletState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _transactionControllerUseCase =
      ref.read(transactionControllerUseCaseProvider);
  late final _tweetsUseCase = ref.read(tweetsUseCaseProvider);
  late final _customTokenUseCase = ref.read(customTokensUseCaseProvider);
  late final _balanceUseCase = ref.read(balanceHistoryUseCaseProvider);
  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);
  late final _mxcTransactionsUseCase = ref.read(mxcTransactionsUseCaseProvider);
  late final _mxcWebsocketUseCase = ref.read(mxcWebsocketUseCaseProvider);
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _errorUseCase = ref.read(errorUseCaseProvider);
  late final _functionUseCase = ref.read(functionUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_tweetsUseCase.defaultTweets, (v) {
      if (v != null) {
        notify(() => state.embeddedTweets = v.tweets!);
      }
    });

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        final cAccount = state.account;
        notify(() => state.account = value);
        if (state.network != null) {
          getTransactions();
        }
      }
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
        getTransactions();
        resetBalanceUpdateStream();
      }
    });

    listen(_transactionHistoryUseCase.transactionsHistory, (value) {
      if (state.network != null &&
          !MXCChains.isMXCChains(state.network!.chainId)) {
        getCustomChainsTransactions(value);
        initBalanceUpdateStream();
      }
    });

    listen(_accountUserCase.xsdConversionRate, (value) {
      notify(() => state.xsdConversionRate = value);
    });

    listen(_balanceUseCase.balanceHistory, (newBalanceHistory) {
      if (newBalanceHistory.isNotEmpty) {
        generateChartData(newBalanceHistory);
      }
    });

    listen(_tokenContractUseCase.tokensList, (newTokenList) {
      if (newTokenList.isNotEmpty) {
        state.tokensList.clear();
        state.tokensList.addAll(newTokenList);
      }
    });

    listen(_tokenContractUseCase.totalBalanceInXsd, (newValue) {
      notify(() => state.walletBalance = newValue.toString());
      _balanceUseCase
          .addItem(BalanceData(timeStamp: DateTime.now(), balance: newValue));
    });

    listen(_customTokenUseCase.tokens, (customTokens) {
      _tokenContractUseCase.addCustomTokens(
          customTokens,
          state.account?.address ?? _accountUserCase.account.value!.address,
          MXCChains.isMXCChains(state.network!.chainId) ||
              MXCChains.isEthereumMainnet(state.network!.chainId));
      initializeBalancePanelAndTokens();
    });

    listen(_mxcWebsocketUseCase.addressStream, (value) {
      _functionUseCase.onlyMXCChainsFuncWrapper(() {
        if (state.subscription != null) {
          state.subscription!.cancel();
        }

        state.subscription = value.listen(handleWebSocketEvents);
      });
    });
  }

  @override
  Future<void> dispose() async {
    if (state.subscription != null) state.subscription!.cancel();
    super.dispose();
  }

  changeIndex(newIndex) {
    notify(() => state.currentIndex = newIndex);
  }

  handleWebSocketEvents(dynamic event) {
    if (!mounted) return;
    switch (event.event.value as String) {
      // coin transfer pending tx token transfer - coin transfer
      case 'pending_transaction':
        final newTx = MoonchainTransactionModel.fromJson(
            json.encode(event.payload['transactions'][0]));
        if (newTx.value != null) {
          notify(() => state.txList!.insert(
              0,
              TransactionModel.fromMXCTransaction(
                  newTx, state.account!.address)));
        }
        final newTxList =
            _mxcTransactionsUseCase.checkPendingTx(state.txList ?? []);
        notify(() => state.txList = newTxList);
        break;
      // coin transfer done
      case 'transaction':
        // Sometimes getting the tx list from remote right away, results in having the pending tx in the list too (Which shouldn't be)
        Future.delayed(const Duration(seconds: 3), () {
          getMXCTransactions();
        });
        break;
      // new balance
      case 'balance':
        final wannseeBalanceEvent =
            MoonchainBalanceEvenModel.fromJson(event.payload);
        getWalletTokensBalance(null, true);
        break;
      default:
    }
  }

  void getTransactions() async {
    if (MXCChains.isMXCChains(state.network!.chainId)) {
      getMXCTransactions();
    } else {
      getCustomChainsTransactions(null);
    }
  }

  void getCustomChainsTransactions(List<TransactionModel>? txHistory) {
    txHistory =
        txHistory ?? _transactionHistoryUseCase.getTransactionsHistory();
    final chainTxHistory = txHistory;

    notify(() => state.txList = chainTxHistory);
  }

  void getMXCTransactions() async {
    final txList = await _mxcTransactionsUseCase
        .getMXCTransactions(state.account!.address);

    // looks like error
    state.isTxListLoading = false;
    notify(() => state.txList = txList);
  }

  initializeBalancePanelAndTokens() {
    getDefaultTokens().then((tokenList) => getWalletTokensBalance(
        tokenList,
        MXCChains.isMXCChains(state.network!.chainId) ||
            MXCChains.isEthereumMainnet(state.network!.chainId)));
  }

  Future<List<Token>> getDefaultTokens() async {
    return await _tokenContractUseCase.getDefaultTokens(state.account!.address);
  }

  void changeHideBalanceState() {
    notify(() => state.hideBalance = !state.hideBalance);
  }

  void viewTransaction(String txHash) async {
    _launcherUseCase.viewTransaction(txHash);
  }

  void getViewOtherTransactionsLink() async {
    _launcherUseCase.viewTransactions(state.txList!);
  }

  void generateChartData(List<BalanceData> balanceData) {
    final List<FlSpot> newBalanceSpots = [];
    double newMaxValue = 0.0;

    final sampleBalance = balanceData[0].balance;
    final allSame =
        balanceData.every((element) => element.balance == sampleBalance);

    if (allSame == true) {
      // we have only one day data
      final balance = balanceData[0].balance;
      newMaxValue = balance * 2.0;
    }

    for (int i = 0; i < balanceData.length; i++) {
      final data = balanceData.elementAt(i);

      final balance = data.balance;
      if (newMaxValue < balance) {
        newMaxValue = balance;
      }

      if ((i + 1) == balanceData.length) {
        // last data
        // fill the list
        newBalanceSpots.addAll(List.generate(
            7 - newBalanceSpots.length,
            (index) =>
                FlSpot((newBalanceSpots.length + index).toDouble(), balance)));
      } else {
        final nextData = balanceData.elementAt(i + 1);
        final sevenDaysBefore =
            DateTime.now().subtract(const Duration(days: 7));

        if (i == 0) {
          final difference = data.timeStamp.difference(sevenDaysBefore).inDays;
          if (!difference.isNegative) {
            newBalanceSpots.addAll(List.generate(
                difference,
                (index) => FlSpot(
                    (newBalanceSpots.length + index).toDouble(), balance)));
          }
        }

        final timeGap = nextData.timeStamp
            .difference(
              data.timeStamp,
            )
            .inDays;

        newBalanceSpots.addAll(List.generate(
            timeGap,
            (index) =>
                FlSpot((newBalanceSpots.length + index).toDouble(), balance)));
      }
    }

    if (newBalanceSpots.isNotEmpty) {
      if (newBalanceSpots.length < 7) {
        final lastBalance = newBalanceSpots[newBalanceSpots.length - 1].y;
        final endingBalances = List.generate(
            7 - newBalanceSpots.length,
            (index) => FlSpot(
                (newBalanceSpots.length + index).toDouble(), lastBalance));
        newBalanceSpots.addAll(endingBalances);
      }
      state.balanceSpots.clear();
      notify(() => state.balanceSpots.addAll(newBalanceSpots));
      notify(() => state.chartMaxAmount = newMaxValue);
      calculateTheChange();
    }
  }

  void calculateTheChange() {
    try {
      final yesterdayBalance = state.balanceSpots[5].y;

      final balanceDifference =
          double.parse(state.walletBalance) - yesterdayBalance;

      if (balanceDifference == 0) {
        notify(() => state.changeIndicator = 0);
      } else {
        notify(() =>
            state.changeIndicator = balanceDifference * 100 / yesterdayBalance);
      }
    } catch (e) {
      addError(e.toString());
    }
  }

  void getWalletTokensBalance(
      List<Token>? tokenList, bool shouldGetPrice) async {
    _tokenContractUseCase.getTokensBalance(
        tokenList, state.account!.address, shouldGetPrice);
  }

  void checkMaxTweetHeight(double height) {
    if (height >= state.maxTweetViewHeight - 120) {
      notify(() => state.maxTweetViewHeight = height + 120);
    }
  }

  void initBalanceUpdateStream() {
    state.balancesUpdateSubscription ??=
        listen(_transactionHistoryUseCase.shouldUpdateBalances, (value) {
      if (value) initializeBalancePanelAndTokens();
    });
  }

  void resetBalanceUpdateStream() {
    if (MXCChains.isMXCChains(state.network!.chainId) &&
        state.balancesUpdateSubscription != null) {
      state.balancesUpdateSubscription!.cancel();
      state.balancesUpdateSubscription = null;
    }
  }

  void cancelTransaction(TransactionModel transaction) async {
    final from = state.account!.address;
    final to = from;
    TransactionGasEstimation estimation =
        await _tokenContractUseCase.estimateGasFeeForCoinTransfer(
            from: from, to: to, value: EtherAmount.zero());

    final estimatedPriorityFees = MXCGas.addExtraFeeToPriorityFees(
        feePerGas: transaction.feePerGas!,
        priorityFeePerGas: transaction.maxPriorityFee!.toDouble());

    final estimatedGasPriceDouble = estimation.gasPrice.getInWei.toDouble();

    final totalFee = MXCGas.getTotalFeeInString(
        estimatedGasPriceDouble, transaction.gasLimit!);

    // Increasing max fee per gas
    final maxPriorityFeePerGas =
        MxcAmount.fromDoubleByWei(estimatedPriorityFees.maxPriorityFeePerGas);
    final estimatedMaxFeePerGas = estimatedPriorityFees.maxFeePerGas;

    double finalMaxFeePerGas = MXCGas.getReplacementMaxFeePerGas(
        estimatedGasPriceDouble, estimatedMaxFeePerGas);

    final maxFeePerGas = MxcAmount.fromDoubleByWei(finalMaxFeePerGas);

    final totalMaxFee =
        MXCGas.getTotalFeeInString(finalMaxFeePerGas, transaction.gasLimit!);

    final result = await showCancelDialog(context!,
        estimatedFee: totalFee,
        maxFee: totalMaxFee,
        symbol: state.network!.symbol);

    if (result ?? false) {
      TransactionModel newPendingTransaction =
          await _transactionControllerUseCase.cancelTransaction(
              transaction, state.account!, maxFeePerGas, maxPriorityFeePerGas);

      _transactionHistoryUseCase.replaceCancelTransaction(
          transaction, newPendingTransaction, state.network!.chainId);
    }
  }

  void speedUpTransaction(TransactionModel transaction) async {
    try {
      final from = transaction.from!;
      final to = transaction.to!;

      EtherAmount? value;
      if (transaction.type == TransactionType.sent &&
          transaction.value != null &&
          transaction.transferType != TransferType.erc20) {
        value = MxcAmount.fromStringByWei(transaction.value!);
      }

      BigInt? gasLimit = transaction.gasLimit != null
          ? BigInt.from(transaction.gasLimit!)
          : null;
      Uint8List? data = transaction.data != null && transaction.data != '0x'
          ? MXCType.hexToUint8List(transaction.data!)
          : null;

      late TransactionGasEstimation estimation;

      if (data == null) {
        estimation = await _tokenContractUseCase.estimateGasFeeForCoinTransfer(
            from: from, to: to, value: value!);
      } else {
        estimation = await _tokenContractUseCase.estimateGasFeeForContractCall(
            from: from,
            to: to,
            data: data,
            amountOfGas: gasLimit,
            value: value);
      }

      // updating these fields with extraGasPercentage
      final estimatedPriorityFees = MXCGas.addExtraFeeToPriorityFees(
          feePerGas: transaction.feePerGas!,
          priorityFeePerGas: transaction.maxPriorityFee!.toDouble());

      final estimatedGasPriceDouble = estimation.gasPrice.getInWei.toDouble();

      final totalFee = MXCGas.getTotalFeeInString(
          estimatedGasPriceDouble, transaction.gasLimit!);

      final maxPriorityFeePerGas =
          MxcAmount.fromDoubleByWei(estimatedPriorityFees.maxPriorityFeePerGas);
      final estimatedMaxFeePerGas = estimatedPriorityFees.maxFeePerGas;

      double finalMaxFeePerGas = MXCGas.getReplacementMaxFeePerGas(
          estimatedGasPriceDouble, estimatedMaxFeePerGas);

      final maxFeePerGas = MxcAmount.fromDoubleByWei(finalMaxFeePerGas);

      final totalMaxFee =
          MXCGas.getTotalFeeInString(finalMaxFeePerGas, transaction.gasLimit!);

      final result = await showSpeedUpDialog(context!,
          estimatedFee: totalFee,
          maxFee: totalMaxFee,
          symbol: state.network!.symbol);

      if (result ?? false) {
        TransactionModel newPendingTransaction =
            await _transactionControllerUseCase.speedUpTransaction(transaction,
                state.account!, maxFeePerGas, maxPriorityFeePerGas);

        _transactionHistoryUseCase.replaceSpeedUpTransaction(
            transaction, newPendingTransaction, state.network!.chainId);
      }
    } catch (e, s) {
      callErrorHandler(e, s);
    }
  }

  void callErrorHandler(dynamic e, StackTrace s) {
    final isHandled =
        _errorUseCase.handleError(context!, e, addError, translate);
    if (!isHandled) {
      addError(e, s);
    }
  }
}
