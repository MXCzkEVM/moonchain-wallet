import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:mxc_logic/mxc_logic.dart';

enum SortType { decrease, increase }

enum SortOption { date, amount }

class FilterAndSortItems extends StatefulWidget {
  const FilterAndSortItems({
    Key? key,
    this.transactionType = TransactionType.all,
    this.sortOption = SortOption.date,
    this.dateSort = SortType.decrease,
    this.amountSort = SortType.increase,
    this.onTap,
  }) : super(key: key);

  final TransactionType transactionType;
  final SortOption sortOption;
  final SortType dateSort;
  final SortType amountSort;
  final Function(TransactionType transactionType, SortOption sortOption,
      SortType dateSort, SortType amountSort)? onTap;

  @override
  State<FilterAndSortItems> createState() => _FilterAndSortItemsState();
}

class _FilterAndSortItemsState extends State<FilterAndSortItems> {
  TransactionType transactionType = TransactionType.all;
  SortOption currenSortOption = SortOption.date;
  SortType dateSort = SortType.decrease;
  SortType amountSort = SortType.increase;

  @override
  void initState() {
    super.initState();

    transactionType = widget.transactionType;
    currenSortOption = widget.sortOption;
    dateSort = widget.dateSort;
    amountSort = widget.amountSort;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title('filter'),
        ...{
          'all_transactions': TransactionType.all,
          'send_transactions': TransactionType.sent,
          'receive_transactions': TransactionType.received,
          'contract_call_transactions': TransactionType.contractCall
        }
            .entries
            .map(
              (e) => filterItem(
                e.key,
                e.value,
              ),
            )
            .toList(),
        title('sort'),
        sortItem(
          'date',
          dateSort == SortType.decrease ? 'new_to_old' : 'old_to_new',
          dateSort,
          sortOption: SortOption.date,
          onTap: () {
            setState(() {
              currenSortOption = SortOption.date;
              dateSort = dateSort == SortType.increase
                  ? SortType.decrease
                  : SortType.increase;
            });
          },
        ),
        sortItem(
          'amount',
          amountSort == SortType.increase ? 'low_to_high' : 'high_to_low',
          amountSort,
          sortOption: SortOption.amount,
          onTap: () {
            setState(() {
              currenSortOption = SortOption.amount;
              amountSort = amountSort == SortType.increase
                  ? SortType.decrease
                  : SortType.increase;
            });
          },
        ),
        const SizedBox(height: 8),
        MxcButton.primary(
            key: const ValueKey('transactionButton'),
            size: MXCWalletButtonSize.xl,
            title: FlutterI18n.translate(context, 'done'),
            onTap: () {
              Navigator.of(context).pop();

              widget.onTap!(
                transactionType,
                currenSortOption,
                dateSort,
                amountSort,
              );
            }),
      ],
    );
  }

  Widget title(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        FlutterI18n.translate(context, text),
        style: FontTheme.of(context).body1.secondary(),
      ),
    );
  }

  Widget filterItem(String typeText, TransactionType currentType) {
    return InkWell(
      onTap: () {
        setState(() => transactionType = currentType);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              FlutterI18n.translate(context, typeText),
              style: FontTheme.of(context).body2.primary(),
            ),
          ),
          transactionType == currentType
              ? const Icon(Icons.check_rounded)
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget sortItem(
    String sortText,
    String selectText,
    SortType sortType, {
    SortOption sortOption = SortOption.date,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              FlutterI18n.translate(context, sortText),
              style: FontTheme.of(context).body2.primary(),
            ),
          ),
          Visibility(
            visible: currenSortOption == sortOption,
            child: Row(
              children: [
                Text(
                  FlutterI18n.translate(context, selectText),
                  style: FontTheme.of(context).body1.secondary(),
                ),
                const SizedBox(width: 2),
                Icon(sortType == SortType.increase
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
