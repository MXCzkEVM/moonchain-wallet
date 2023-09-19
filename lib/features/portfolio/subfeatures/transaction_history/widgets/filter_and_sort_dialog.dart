import 'package:datadashwallet/common/common.dart';
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
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 44),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).screenBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
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
    ),
  );
}
