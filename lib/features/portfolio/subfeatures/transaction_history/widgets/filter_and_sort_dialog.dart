import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';
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
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxcAppBarEvenly.title(
          titleText: FlutterI18n.translate(context, 'filter_&_sort'),
          action: Container(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: const Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
        FilterAndSortItems(
          transactionType: transactionType,
          sortOption: sortOption,
          dateSort: dateSort,
          amountSort: amountSort,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}
