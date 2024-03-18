import 'dart:typed_data';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/common/components/recent_transactions/widgets/widgets.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
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
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _errorUseCase = ref.read(errorUseCaseProvider);

  @override
  void initState() {
    super.initState();

    getMXCTweets();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        final cAccount = state.account;
        notify(() => state.account = value);
        if (cAccount != null && cAccount.address != value.address) {
          /// Not first time & there is a change
          Utils.retryFunction(connectAndSubscribe);
        }
        if (state.network != null) {
          getTransactions();
        }
      }
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
        Utils.retryFunction(connectAndSubscribe);
        getTransactions();
        resetBalanceUpdateStream();
      }
    });

    listen(_transactionHistoryUseCase.transactionsHistory, (value) {
      if (state.network != null &&
          !Config.isMxcChains(state.network!.chainId)) {
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
      state.tokensList.clear();
      state.tokensList.addAll(newTokenList);
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
          Config.isMxcChains(state.network!.chainId) ||
              Config.isEthereumMainnet(state.network!.chainId));
      initializeBalancePanelAndTokens();
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

  void connectAndSubscribe() async {
    if (!Config.isMxcChains(state.network!.chainId)) {
      if (state.subscription != null) state.subscription!.cancel();
      disconnectWebsocket();
      return;
    }

    if (state.network?.web3WebSocketUrl?.isNotEmpty ?? false) {
      final isConnected = await connectToWebsocket();
      if (isConnected) {
        createSubscriptions();
      } else {
        throw 'Couldn\'t connect';
      }
    }
  }

  Future<bool> connectToWebsocket() async {
    return await _tokenContractUseCase.connectToWebsSocket();
  }

  void disconnectWebsocket() async {
    return _tokenContractUseCase.disconnectWebsSocket();
  }

  Future<Stream<dynamic>?> subscribeToBalance() async {
    return await _tokenContractUseCase.subscribeEvent(
      "addresses:${state.account!.address}".toLowerCase(),
    );
  }

  void createSubscriptions() async {
    final subscription = await subscribeToBalance();

    if (subscription == null) {
      createSubscriptions();
    }

    if (state.subscription != null) state.subscription!.cancel();
    state.subscription = subscription!.listen(handleWebSocketEvents);
  }

  handleWebSocketEvents(dynamic event) {
    if (!mounted) return;
    switch (event.event.value as String) {
      // coin transfer pending tx token transfer - coin transfer
      case 'pending_transaction':
        final newTx = WannseeTransactionModel.fromJson(
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
        // final newMXCTx = WannseeTransactionModel.fromJson(
        //     json.encode(event.payload['transactions'][0]));

        // final newTx = TransactionModel.fromMXCTransaction(
        //     newMXCTx, state.account!.address);

        // if (newTx.token.symbol == Config.mxcName &&
        //     newTx.type == TransactionType.received) {
        //   final decimal = newTx.token.decimals ?? Config.ethDecimals;
        //   final formattedValue =
        //       MXCFormatter.convertWeiToEth(newTx.value ?? '0', decimal);
        //   showNotification(
        //       translate('mxc_top_up_notification_title')!,
        //       translate('mxc_top_up_notification_text')!
        //           .replaceFirst(
        //             '{0}',
        //             state.account!.mns ??
        //                 MXCFormatter.formatWalletAddress(
        //                     state.account!.address),
        //           )
        //           .replaceFirst('{1}', formattedValue));
        // }
        // Sometimes getting the tx list from remote right away, results in having the pending tx in the list too (Which shouldn't be)
        Future.delayed(const Duration(seconds: 3), () {
          getMXCTransactions();
        });
        break;
      // new balance
      case 'balance':
        final wannseeBalanceEvent = WannseeBalanceModel.fromJson(event.payload);
        getWalletTokensBalance(null, true);
        break;
      default:
    }
  }

  void getTransactions() async {
    if (Config.isMxcChains(state.network!.chainId)) {
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
        Config.isMxcChains(state.network!.chainId) ||
            Config.isEthereumMainnet(state.network!.chainId)));
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
    _launcherUseCase.viewTransactions();
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

  void getMXCTweets() async {
    try {
      final defaultTweets = await _tweetsUseCase.getDefaultTweets();
      notify(() => state.embeddedTweets = defaultTweets.tweets!);
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
    if (Config.isMxcChains(state.network!.chainId) &&
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
