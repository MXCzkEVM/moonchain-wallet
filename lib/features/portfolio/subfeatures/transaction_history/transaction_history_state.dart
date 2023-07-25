import 'package:datadashwallet/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'widgets/filter_and_sort_items.dart';

class TransactionHistoryState with EquatableMixin {
  String? walletAddress;
  WannseeTransactionsModel? transactions;
  List<Token> tokens = [];

  WannseeTransactionsModel? filterTransactions;

  TransactionType transactionType = TransactionType.all;
  SortOption sortOption = SortOption.date;
  SortType dateSort = SortType.decrease;
  SortType amountSort = SortType.increase;

  @override
  List<Object?> get props => [
        walletAddress,
        transactions,
        tokens,
        filterTransactions,
        transactionType,
        sortOption,
        dateSort,
        amountSort,
      ];
}
