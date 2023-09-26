import 'package:datadashwallet/common/components/recent_transactions/utils.dart';
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
  }

  Future<void> loadPage() async {
    await _tokenContractUseCase
        .getDefaultTokens(state.account!.address)
        .then((value) {
      if (value != null) {
        notify(() => state.tokens = value.tokens!);
        getTransactions();
      }
    });
  }

  void getTransactions() async {
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
        if (newTransactionsList.items != null) {
          newTransactionsList = newTransactionsList.copyWith(
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
          for (int i = 0; i < newTokenTransfersList.items!.length; i++) {
            final item = newTokenTransfersList.items![i];
            newTransactionsList.items!
                .add(WannseeTransactionModel(tokenTransfers: [item]));
          }
          if (newTransactionsList.items!.isNotEmpty) {
            newTransactionsList.items!.sort((a, b) {
              final item1 = a.timestamp ?? a.tokenTransfers![0].timestamp;
              final item2 = b.timestamp ?? b.tokenTransfers![0].timestamp;

              return item2!.compareTo(item1!);
            });
          }

          final sevenDays = DateTime.now().subtract(const Duration(days: 7));
          newTransactionsList = newTransactionsList.copyWith(
              items: newTransactionsList.items!.where((element) {
            if (element.timestamp != null) {
              return element.timestamp!.isAfter(sevenDays);
            }
            return element.tokenTransfers![0].timestamp!.isAfter(sevenDays);
          }).toList());

          newTransactionsList = newTransactionsList.copyWith(
              items: newTransactionsList.items!.where((element) {
            if (element.timestamp != null) {
              return element.timestamp!.isAfter(sevenDays);
            }
            return element.tokenTransfers![0].timestamp!.isAfter(sevenDays);
          }).toList());

          final newTxList = newTransactionsList.items!
              .map((e) => TransactionModel.fromMXCTransaction(
                  e, state.account!.address))
              .toList();
          newTxList.removeWhere(
            (element) => element.hash == "Unknown",
          );

          notify(() {
            state.transactions = newTxList;
            state.filterTransactions = newTxList;
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
            final item1 = double.parse(a.value);
            final item2 = double.parse(b.value);

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
