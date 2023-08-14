import 'dart:developer';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/common/components/recent_transactions/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
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

  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.walletAddress, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value);
        loadPage();
      }
    });

    loadPage();
  }

  Future<void> loadPage() async {
    await _tokenContractUseCase.getDefaultTokens(state.walletAddress!);
    getTransactions();
  }

  void getTransactions() async {
    // final walletAddress = await _walletUserCase.getPublicAddress();
    // transactions list contains all the kind of transactions
    // It's going to be filtered to only have native coin transfer
    await _tokenContractUseCase
        .getTransactionsByAddress(state.walletAddress!)
        .then((newTransactionsList) async {
      // token transfer list contains only one kind transaction which is token transfer
      final newTokenTransfersList = await _tokenContractUseCase
          .getTokenTransfersByAddress(state.walletAddress!);

      if (newTokenTransfersList != null && newTransactionsList != null) {
        // loading over and we have the data
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
              final item1 = a.timestamp ?? a.tokenTransfers![0].timestamp;
              final item2 = b.timestamp ?? b.tokenTransfers![0].timestamp;

              return item2!.compareTo(item1!);
            });
          }

          final sevenDays = DateTime.now().subtract(const Duration(days: 7));
          final finalList = newTransactionsList.copyWith(
              items: newTransactionsList.items!.where((element) {
            if (element.timestamp != null) {
              return element.timestamp!.isAfter(sevenDays);
            }
            return element.tokenTransfers![0].timestamp!.isAfter(sevenDays);
          }).toList());

          notify(() {
            state.transactions = newTransactionsList;
            state.filterTransactions =
                WannseeTransactionsModel(items: finalList.items);
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

        if (state.transactions == null || state.transactions?.items == null) {
          return;
        }

        var result = state.transactions!.items!.where((item) {
          if (transactionType == TransactionType.all) return true;

          if (item.from == null || item.from?.hash == null) {
            return false;
          }

          final type = RecentTransactionsUtils.checkForTransactionType(
              state.walletAddress!, item.from!.hash!.toLowerCase());
          return transactionType == type;
        }).toList();

        result.sort((a, b) {
          if (SortOption.date == sortOption) {
            final item1 = a.timestamp ?? a.tokenTransfers![0].timestamp;
            final item2 = b.timestamp ?? b.tokenTransfers![0].timestamp;

            if (SortType.increase == dateSort) {
              return item1!.compareTo(item2!);
            } else {
              return item2!.compareTo(item1!);
            }
          } else {
            final item1 = double.parse(
                a.value ?? a.tokenTransfers?[0].total?.value ?? '0');
            final item2 = double.parse(
                b.value ?? b.tokenTransfers?[0].total?.value ?? '0');

            if (SortType.increase == amountSort) {
              return item1.compareTo(item2);
            } else {
              return item2.compareTo(item1);
            }
          }
        });

        notify(() => state.filterTransactions =
            state.filterTransactions?.copyWith(items: result));
      },
    );
  }
}
