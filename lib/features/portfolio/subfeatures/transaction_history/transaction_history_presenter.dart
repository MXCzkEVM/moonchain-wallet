import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'transaction_history_state.dart';
import 'widgets/filter_and_sort_dialog.dart';
import 'widgets/filter_and_sort_items.dart';

final transactionHistoryPageContainer =
    PresenterContainer<TransactionHistoryPresenter, TransactionHistoryState>(
        () => TransactionHistoryPresenter());

class TransactionHistoryPresenter
    extends CompletePresenter<TransactionHistoryState> {
  TransactionHistoryPresenter() : super(TransactionHistoryState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);
  late final _mxcTransactionsUseCase = ref.read(mxcTransactionsUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
      }
    });

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.account = value);
        loadPage();
      }
    });

    listen(_transactionHistoryUseCase.transactionsHistory, (value) {
      if (state.network != null) {
        if (!MXCChains.isMXCChains(state.network!.chainId)) {
          getCustomChainsTransactions(value);
        }
      }
    });
  }

  Future<void> loadPage() async {
    await _tokenContractUseCase
        .getDefaultTokens(state.account!.address)
        .then((value) {
      notify(() => state.tokens = value);
      getTransactions();
    });
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

    if (state.network != null) {
      final chainTxHistory = txHistory;

      notify(() {
        state.transactions = chainTxHistory;
        state.filterTransactions = chainTxHistory;
      });
    }
  }

  void getMXCTransactions() async {
    // final walletAddress = await _walletUserCase.getPublicAddress();
    // transactions list contains all the kind of transactions
    // It's going to be filtered to only have native coin transfer
    await _tokenContractUseCase
        .getTransactionsByAddress(state.account!.address)
        .then((newTransactionsList) async {
      // token transfer list contains only one kind transaction which is token transfer
      final newTokenTransfersList = await _tokenContractUseCase
          .getTokenTransfersByAddress(state.account!.address);

      if (newTokenTransfersList != null && newTransactionsList != null) {
        // loading over and we have the data
        // merge
        newTransactionsList = newTransactionsList.copyWith(
            items: _mxcTransactionsUseCase.removeTokenTransfersFromTxList(
                newTransactionsList.items!, newTokenTransfersList.items!));

        if (newTokenTransfersList.items != null) {
          _mxcTransactionsUseCase.addTokenTransfersToTxList(
              newTransactionsList.items!, newTokenTransfersList.items!);

          _mxcTransactionsUseCase.sortByDate(newTransactionsList.items!);

          final sevenDays = DateTime.now()
              .subtract(Duration(days: Config.transactionsHistoryLimit));

          List<TransactionModel> finalTxList =
              _mxcTransactionsUseCase.axsTxListFromMxcTxList(
                  newTransactionsList.items!, state.account!.address);

          finalTxList = _mxcTransactionsUseCase.applyTxDateLimit(finalTxList);

          _mxcTransactionsUseCase.removeInvalidTx(finalTxList);

          notify(() {
            state.transactions = finalTxList;
            state.filterTransactions = finalTxList;
          });
        }
      }
    });
  }

  void fliterAndSort() {
    showFilterAndSortDialog(
      context!,
      transactionType: state.transactionType,
      sortOption: state.sortOption,
      dateSort: state.dateSort,
      amountSort: state.amountSort,
      onTap: (
        TransactionType transactionType,
        SortOption sortOption,
        SortType dateSort,
        SortType amountSort,
      ) {
        state.transactionType = transactionType;
        state.sortOption = sortOption;
        state.dateSort = dateSort;
        state.amountSort = amountSort;

        if (state.transactions == null) {
          return;
        }

        var result = state.transactions!.where((item) {
          if (transactionType == TransactionType.all) return true;

          return transactionType == item.type;
        }).toList();

        if (SortOption.amount == sortOption) {
          result = state.transactions!.where((item) {
            return TransactionType.contractCall != item.type;
          }).toList();
        }

        result.sort((a, b) {
          if (SortOption.date == sortOption) {
            final item1 = a.timeStamp;
            final item2 = b.timeStamp;

            if (item1 == null || item2 == null) return 0;

            if (SortType.increase == dateSort) {
              return item1.compareTo(item2);
            } else {
              return item2.compareTo(item1);
            }
          } else {
            final item1 = double.parse(a.value!);
            final item2 = double.parse(b.value!);

            if (SortType.increase == amountSort) {
              return item1.compareTo(item2);
            } else {
              return item2.compareTo(item1);
            }
          }
        });

        notify(() => state.filterTransactions = result);
      },
    );
  }
}
