import 'package:datadashwallet/common/common.dart';
import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'widgets/filter_and_sort_items.dart';

class TransactionHistoryState with EquatableMixin {
  Account? account;
  WannseeTransactionsModel? transactions;
  List<Token> tokens = [];

  WannseeTransactionsModel? filterTransactions;

  TransactionType transactionType = TransactionType.all;
  SortOption sortOption = SortOption.date;
  SortType dateSort = SortType.decrease;
  SortType amountSort = SortType.increase;

  @override
  List<Object?> get props => [
        account,
        transactions,
        tokens,
        filterTransactions,
        transactionType,
        sortOption,
        dateSort,
        amountSort,
      ];
}
