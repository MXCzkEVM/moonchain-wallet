import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/widgets/nft_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_dialog.dart';

class TransactionInfo extends StatelessWidget {
  const TransactionInfo(
      {Key? key,
      required this.nft,
      required this.newtork,
      required this.from,
      required this.to,
      this.estimatedFee,
      this.processType = TransactionProcessType.confirm,
      this.onTap,
      required this.symbol})
      : super(key: key);

  final Nft nft;
  final String newtork;
  final String from;
  final String to;
  final String? estimatedFee;
  final TransactionProcessType? processType;
  final String symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              imageItem(context, nft),
              addressItem(context, 'from', from),
              addressItem(context, 'to', to),
              if (TransactionProcessType.confirm != processType)
                priceItem(context, 'estimated_fee', estimatedFee, symbol),
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
    MXCWalletButtonType type = MXCWalletButtonType.primary;

    if (processType == TransactionProcessType.send) {
      titleText = 'send';
    } else if (processType == TransactionProcessType.done) {
      titleText = 'done';
      type = MXCWalletButtonType.pass;
    }

    return MxcButton.primary(
      key: const ValueKey('transactionButton'),
      size: MXCWalletButtonSize.xl,
      title: FlutterI18n.translate(context, titleText),
      type: type,
      onTap: () {
        if (onTap != null) onTap!();
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget imageItem(BuildContext context, Nft nft) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          FlutterI18n.translate(context, 'sending_x')
              .replaceFirst('{0}', nft.name),
          style: FontTheme.of(context).subtitle1.secondary(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: NFTItem(
            imageUrl: nft.image,
          ),
        ),
      ],
    );
  }

  Widget priceItem(
      BuildContext context, String label, String? price, String symbol) {
    return TransactionItem(
      label: label,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            price != null
                ? MXCFormatter.formatNumberForUI(
                    price,
                  )
                : '--',
            style: FontTheme.of(context).body1.primary(),
          ),
          const SizedBox(width: 4),
          Text(
            'MXC',
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
        // onTap: () =>
        //     openUrl('https://wannsee-explorer.mxc.com/address/$address'),
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
