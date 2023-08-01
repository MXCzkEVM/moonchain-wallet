import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wallet_page_state.dart';

final walletContainer =
    PresenterContainer<WalletPresenter, WalletState>(() => WalletPresenter());

class WalletPresenter extends CompletePresenter<WalletState> {
  WalletPresenter() : super(WalletState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _customTokenUseCase = ref.read(customTokensUseCaseProvider);
  late final _balanceUseCase = ref.read(balanceHistoryUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value.address);
        initializeWalletPage();
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

    listen(_contractUseCase.tokensList, (newTokenList) {
      if (newTokenList.isNotEmpty) {
        state.tokensList.clear();
        state.tokensList.addAll(newTokenList);
      }
    });

    listen(_customTokenUseCase.tokens, (customTokens) {
      if (customTokens.isNotEmpty) {
        _contractUseCase.addCustomTokens(customTokens);
      }
    });

    _accountUserCase.refreshWallet();
  }

  changeIndex(newIndex) {
    notify(() => state.currentIndex = newIndex);
  }

  Future<void> initializeWalletPage() async {
    getDefaultTokens();
    getBalance();
    createSubscriptions();
    getTransactions();
  }

  getBalance() async {
    try {
      final balanceUpdate = await _contractUseCase
          .getWalletNativeTokenBalance(state.walletAddress!);
      notify(() => state.walletBalance = balanceUpdate);
      _balanceUseCase.addItem(BalanceData(
          timeStamp: DateTime.now(), balance: double.parse(balanceUpdate)));
    } catch (e) {
      // Balance not found error happens if the wallet is new
      // But the error object that is thrown is not exported be used here
      // RPCError
      // if (e.message == 'Balance not found') {

      // }
      // The balance might not be found
    }
  }

  void createSubscriptions() async {
    _contractUseCase.subscribeToBalance(
      "addresses:${state.walletAddress}".toLowerCase(),
      (dynamic event) {
        switch (event.event.value as String) {
          // coin transfer pending tx token transfer - coin transfer
          case 'pending_transaction':
            final newTx = WannseeTransactionModel.fromJson(
                json.encode(event.payload['transactions'][0]));
            if (newTx.value != null) {
              notify(() => state.txList!.items!.insert(0, newTx));
            }
            break;
          // coin transfer done
          case 'transaction':
            final newTx = WannseeTransactionModel.fromJson(
                json.encode(event.payload['transactions'][0]));
            if (newTx.value != null) {
              // We will filter token_transfer tx because It is also received from token_transfer event
              if (newTx.txTypes != null &&
                  !(newTx.txTypes!.contains('token_transfer'))) {
                final itemIndex = state.txList!.items!
                    .indexWhere((txItem) => txItem.hash == newTx.hash);
                // checking for if the transaction is found.
                if (itemIndex != -1) {
                  notify(() => state.txList!.items!
                      .replaceRange(itemIndex, itemIndex + 1, [newTx]));
                } else {
                  // we must have missed the pending tx
                  notify(() => state.txList!.items!.insert(0, newTx));
                }
              }
            }
            break;
          // token transfer pending
          case 'token_transfer':
            final newTx = TokenTransfer.fromJson(
                json.encode(event.payload['token_transfers'][0]));
            if (newTx.txHash != null) {
              // Sender will get pending tx
              // Receiver won't get pending tx
              final itemIndex = state.txList!.items!
                  .indexWhere((txItem) => txItem.hash == newTx.txHash);
              // checking for if the transaction is found.
              if (itemIndex != -1) {
                notify(() => state.txList!.items!
                        .replaceRange(itemIndex, itemIndex + 1, [
                      WannseeTransactionModel(tokenTransfers: [newTx])
                    ]));
              } else {
                // we must have missed the token transfer pending tx
                notify(() => state.txList!.items!.insert(
                      0,
                      WannseeTransactionModel(tokenTransfers: [newTx]),
                    ));
              }
            }
            break;
          // new balance
          case 'balance':
            final wannseeBalanceEvent =
                WannseeBalanceModel.fromJson(event.payload);
            if (wannseeBalanceEvent.balance != null) {
              final newBalance =
                  Formatter.convertWeiToEth(wannseeBalanceEvent.balance!);
              notify(() => state.walletBalance = newBalance);
              _balanceUseCase.addItem(BalanceData(
                  timeStamp: DateTime.now(),
                  balance: double.parse(newBalance)));
            }
            break;
          default:
        }
      },
    );
  }

  void getTransactions() async {
    // final walletAddress = await _walletUserCase.getPublicAddress();
    // transactions list contains all the kind of transactions
    // It's going to be filtered to only have native coin transfer
    await _contractUseCase
        .getTransactionsByAddress(state.walletAddress!)
        .then((newTransactionsList) async {
      // token transfer list contains only one kind transaction which is token transfer
      final newTokenTransfersList = await _contractUseCase
          .getTokenTransfersByAddress(state.walletAddress!);

      if (newTokenTransfersList != null && newTransactionsList != null) {
        // loading over and we have the data
        state.isTxListLoading = false;
        // merge
        if (newTransactionsList.items != null) {
          newTransactionsList.copyWith(
              items: newTransactionsList.items!.where((element) {
            if (element.txTypes != null) {
              return element.txTypes!
                  .any((element) => element == 'coin_transfer');
            } else {
              return false;
            }
          }).toList());
        }

        if (newTokenTransfersList.items != null) {
          for (int i = 1; i < newTokenTransfersList.items!.length; i++) {
            final item = newTokenTransfersList.items![i];
            newTransactionsList.items!
                .add(WannseeTransactionModel(tokenTransfers: [item]));
          }
          if (newTransactionsList.items!.isNotEmpty) {
            newTransactionsList.items!.sort((a, b) {
              if (b.timestamp == null && a.timestamp == null) {
                // both token transfer
                return b.tokenTransfers![0].timestamp!
                    .compareTo(a.tokenTransfers![0].timestamp!);
              } else if (b.timestamp != null && a.timestamp != null) {
                // both coin transfer
                return b.timestamp!.compareTo(a.timestamp!);
              } else if (b.timestamp == null) {
                // b is token transfer
                return b.tokenTransfers![0].timestamp!.compareTo(a.timestamp!);
              } else {
                // a is token transfer
                return b.timestamp!.compareTo(a.tokenTransfers![0].timestamp!);
              }
            });
          }

          notify(() => state.txList = newTransactionsList);
        }
      } else {
        // looks like error
        state.isTxListLoading = false;
      }
    });
  }

  void getTransaction(
    String hash,
  ) async {
    final newTx = await _contractUseCase.getTransactionByHash(hash);

    if (newTx != null) {
      final oldTx = state.txList!.items!
          .firstWhere((element) => element.hash == newTx.hash);
      oldTx.tokenTransfers = [TokenTransfer()];
      oldTx.tokenTransfers![0].from = newTx.tokenTransfers![0].from;
      oldTx.tokenTransfers![0].to = newTx.tokenTransfers![0].to;
      notify(
          () => oldTx.value = newTx.tokenTransfers![0].total!.value.toString());
    }
  }

  void getDefaultTokens() async {
    await _contractUseCase.getDefaultTokens(state.walletAddress!);
  }

  void changeHideBalanceState() {
    notify(() => state.hideBalance = !state.hideBalance);
  }

  void viewTransaction(String txHash) async {
    final addressUrl = Uri.parse('https://wannsee-explorer.mxc.com/tx/$txHash');

    if ((await canLaunchUrl(addressUrl))) {
      await launchUrl(addressUrl, mode: LaunchMode.inAppWebView);
    }
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
    } catch (e) {}
  }
}
