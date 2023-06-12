import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:intl/intl.dart';

enum TransactionType { send, receive }

// extension TransactionTypeExtension on TransactionType {
//   String get name {
//     return this.toString().split('.').last;
//   }
// }

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({Key? key}) : super(key: key);

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  @override
  Widget build(BuildContext context) {
    return GreyContainer(
        padding: const EdgeInsets.all(10),
        child: ListView(
            children: List.generate(10, (index) => RecentTrxListItem())));
  }
}

class RecentTrxListItem extends StatefulWidget {
  const RecentTrxListItem({Key? key}) : super(key: key);

  @override
  State<RecentTrxListItem> createState() => _RecentTrxListItemState();
}

class _RecentTrxListItemState extends State<RecentTrxListItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                    height: 25,
                    width: 25,
                    child: CircleAvatar(
                        backgroundImage: ImagesTheme.of(context).bitcoin)),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '428 USC',
                      style: FontTheme.of(context)
                          .h7()
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    Text(
                        '${FlutterI18n.translate(context, 'tx')} 0xC4ba...e07E',
                        style: FontTheme.of(context).h7().copyWith(
                            fontSize: 12, fontWeight: FontWeight.w400))
                  ],
                ),
              ],
            ),
            Text(
              FlutterI18n.translate(context, TransactionType.send.name),
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorsTheme.of(context).mainRed),
            ),
            Text(
              FlutterI18n.translate(context, 'date'),
              style: FontTheme.of(context)
                  .h7()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            Text(
              DateFormat('m/d/y').format(DateTime.now()),
              style: FontTheme.of(context)
                  .h7()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
