import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'filter_and_sort_items.dart';

enum TransactionProcessType { confirm, send, done }

Future<bool?> showFilterAndSortDialog(
  BuildContext context, {
  TransactionType transactionType = TransactionType.all,
  SortOption sortOption = SortOption.date,
  SortType dateSort = SortType.decrease,
  SortType amountSort = SortType.increase,
  Function(TransactionType transactionType, SortOption sortOption,
          SortType dateSort, SortType amountSort)?
      onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: 'filter_&_sort',
    closeButtonReturnValue: false,
    widgets: [
      FilterAndSortItems(
        transactionType: transactionType,
        sortOption: sortOption,
        dateSort: dateSort,
        amountSort: amountSort,
        onTap: onTap,
      ),
      const SizedBox(height: 10),
    ],
  );
}
