import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_dialog.dart';

class TransactionInfo extends StatelessWidget {
  const TransactionInfo(
      {Key? key,
      required this.amount,
      required this.from,
      required this.to,
      this.estimatedFee,
      this.onTap,
      required this.symbol})
      : super(key: key);

  final String amount;
  final String from;
  final String to;
  final String? estimatedFee;
  final VoidCallback? onTap;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              amountItem(context),
              addressItem(context, 'from', from),
              addressItem(context, 'to', to),
              if (estimatedFee != null)
                priceItem(context, 'estimated_fee', estimatedFee),
            ],
          ),
        ),
        const SizedBox(height: 8),
        transactionButton(context),
      ],
    );
  }

  Widget transactionButton(BuildContext context) {
    String titleText = 'confirm';
    AxsButtonType type = AxsButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('transactionButton'),
      size: AxsButtonSize.xl,
      title: FlutterI18n.translate(context, titleText),
      type: type,
      onTap: () {
        if (onTap != null) onTap!();
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget amountItem(BuildContext context) {
    return Column(
      children: [
        Text(
          FlutterI18n.translate(context, 'sending'),
          style: FontTheme.of(context).subtitle1.secondary(),
        ),
        const SizedBox(width: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Formatter.formatNumberForUI(
                amount,
              ),
              style: FontTheme.of(context).h5(),
              softWrap: true,
            ),
            const SizedBox(width: 4),
            Text(
              symbol,
              style: FontTheme.of(context).h5.secondary(),
            ),
            const SizedBox(height: 4),
          ],
        )
      ],
    );
  }

  Widget priceItem(
    BuildContext context,
    String label,
    String? price,
  ) {
    return TransactionItem(
      label: label,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            price != null
                ? Formatter.formatNumberForUI(
                    price,
                  )
                : '--',
            style: FontTheme.of(context).body1.primary(),
          ),
          const SizedBox(width: 4),
          Text(
            symbol,
            style: FontTheme.of(context).body1().copyWith(
                  color: ColorsTheme.of(context).grey2,
                ),
          ),
        ],
      ),
    );
  }

  Widget textItem(
    BuildContext context,
    String label,
    String value,
  ) {
    return TransactionItem(
      label: label,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: FontTheme.of(context).body1.primary(),
          ),
        ],
      ),
    );
  }

  Widget addressItem(
    BuildContext context,
    String label,
    String address,
  ) {
    return TransactionItem(
      label: label,
      content: InkWell(
        onTap: () =>
            openUrl('https://wannsee-explorer.mxc.com/address/$address'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                address,
                style: FontTheme.of(context).body1.primary(),
                softWrap: true,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              MxcIcons.external_link,
              size: 24,
              color: ColorsTheme.of(context).textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key? key,
    required this.label,
    required this.content,
  }) : super(key: key);

  final String label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                FlutterI18n.translate(context, label),
                style: FontTheme.of(context).body1.secondary(),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
