import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TransactionInfo extends ConsumerWidget {
  const TransactionInfo(
      {Key? key,
      required this.amount,
      required this.from,
      required this.to,
      required this.estimatedFee,
      required this.maxFee,
      this.onTap,
      required this.symbol})
      : super(key: key);

  final String amount;
  final String from;
  final String to;
  final String estimatedFee;
  final String maxFee;
  final VoidCallback? onTap;
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              amountItem(context),
              SingleLineInfoItem(
                title: 'from',
                value: from,
              ),
              SingleLineInfoItem(
                title: 'to',
                value: to,
              ),
              SingleLineInfoItem(
                title: 'estimated_fee',
                value: MXCFormatter.formatNumberForUI(
                  estimatedFee,
                ),
                hint: symbol,
              ),
              SingleLineInfoItem(
                title: 'max_fee',
                value: MXCFormatter.formatNumberForUI(
                  maxFee,
                ),
                hint: symbol,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        transactionButton(context),
      ],
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
              MXCFormatter.formatNumberForUI(
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
}
