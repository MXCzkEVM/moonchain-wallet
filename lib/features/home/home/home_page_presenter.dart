import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'dart:convert';
import 'dart:math';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page_state.dart';

final homeContainer =
    PresenterContainer<HomePresenter, HomeState>(() => HomePresenter());

class HomePresenter extends CompletePresenter<HomeState> {
  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _walletUserCase = ref.read(walletUseCaseProvider);
  HomePresenter() : super(HomeState());

  changeIndex(newIndex) {
    notify(() => state.currentIndex = newIndex);
  }

  @override
  void initState() {
    super.initState();
    _walletUserCase.getPublicAddress().then(
      (walletAddress) {
        // All other services are dependent on the wallet pubic address
        state.walletAddress = walletAddress;
        getDefaultTokens();
        getBalance();
        getTransactions();
        createBalanceSubscription();
      },
    );
  }

  getBalance() async {
    try {
      final balanceUpdate = await _contractUseCase
          .getWalletNativeTokenBalance(state.walletAddress!);
      notify(() => state.walletBalance = balanceUpdate);
    } catch (e) {
      // RPCError
      // if (e.message == 'Balance not found') {

      // }
      // The balance might not be found
    }
  }

  void createBalanceSubscription() async {
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
              notify(() => state.walletBalance =
                  (double.parse(wannseeBalanceEvent.balance!).toDouble() /
                          pow(10, 18))
                      .toStringAsFixed(2));
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
    _contractUseCase
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

  getDefaultTokens() async {
    final defaultTokens = await _contractUseCase.getDefaultTokens();
    if (defaultTokens == null) {
      // retry till success
      getDefaultTokens();
    } else {
      state.defaultTokens = defaultTokens;
    }
  }

  void changeHideBalanceState() {
    notify(() => state.hideBalance = !state.hideBalance);
  }

  void viewMoreTransactions() async {
    if (state.walletAddress != null) {
      final addressUrl = Uri.parse(
          'https://wannsee-explorer.mxc.com/address/${state.walletAddress!.hex}');

      if ((await canLaunchUrl(addressUrl))) {
        await launchUrl(addressUrl, mode: LaunchMode.inAppWebView);
      }
    }
  }

  void viewTransaction(String txHash) async {
    final addressUrl = Uri.parse('https://wannsee-explorer.mxc.com/tx/$txHash');

    if ((await canLaunchUrl(addressUrl))) {
      await launchUrl(addressUrl, mode: LaunchMode.inAppWebView);
    }
  }
}
