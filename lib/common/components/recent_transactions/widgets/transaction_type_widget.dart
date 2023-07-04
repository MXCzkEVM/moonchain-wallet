import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TransactionTypeWidget extends StatelessWidget {
  final Widget transactionStatusChip;
  final String transactionType;
  final Color transactionTypeColor;
  final IconData transactionTypeIcon;
  const TransactionTypeWidget(
      {super.key,
      required this.transactionStatusChip,
      required this.transactionType,
      required this.transactionTypeColor,
      required this.transactionTypeIcon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          transactionTypeIcon,
          size: 18,
          color: transactionTypeColor,
        ),
        const SizedBox(
          width: 4,
        ),
        Row(
          children: [
            Text(
              FlutterI18n.translate(context, transactionType),
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 14,
                  color: transactionTypeColor,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              width: 4,
            ),
            transactionStatusChip
          ],
        )
      ],
    );
  }
}
