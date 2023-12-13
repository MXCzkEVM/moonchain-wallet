import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_dialog.dart';

class TransactionInfo extends StatefulWidget {
  const TransactionInfo({
    Key? key,
    required this.amount,
    required this.balance,
    required this.token,
    required this.network,
    required this.networkSymbol,
    required this.from,
    required this.to,
    required this.estimatedFee,
    required this.maxFee,
    this.processType = TransactionProcessType.confirm,
    required this.onTap,
  }) : super(key: key);

  final String amount;
  final String balance;
  final Token token;
  final String network;
  final String networkSymbol;
  final String from;
  final String to;
  final String estimatedFee;
  final String maxFee;
  final TransactionProcessType? processType;
  final Function(TransactionProcessType) onTap;

  @override
  State<TransactionInfo> createState() => _TransactionInfoState();
}

class _TransactionInfoState extends State<TransactionInfo> {
  TransactionProcessType processType = TransactionProcessType.confirm;
  int index = TransactionProcessType.confirm.index;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxcAppBarEvenly.title(
          titleText: getDialogTitle(),
          action: Container(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: const Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              amountItem(context),
              SingleLineInfoItem(
                title: 'balance',
                value: widget.balance,
                hint: widget.token.symbol,
              ),
              SingleLineInfoItem(
                title: 'network',
                value: widget.network,
              ),
              SingleLineInfoItem(
                title: 'from',
                value: widget.from,
              ),
              SingleLineInfoItem(
                title: 'to',
                value: widget.to,
              ),
              if (TransactionProcessType.confirm != processType) ...[
                SingleLineInfoItem(
                  title: 'estimated_fee',
                  value: MXCFormatter.formatNumberForUI(
                    widget.estimatedFee,
                  ),
                  hint: widget.networkSymbol,
                ),
                SingleLineInfoItem(
                  title: 'max_fee',
                  value: MXCFormatter.formatNumberForUI(
                    widget.maxFee,
                  ),
                  hint: widget.networkSymbol,
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 8),
        transactionButton(context),
      ],
    );
  }

  String getDialogTitle() {
    if (TransactionProcessType.confirm == processType) {
      return FlutterI18n.translate(context, 'confirm_transaction');
    } else {
      return FlutterI18n.translate(context, 'send_x')
          .replaceFirst('{0}', widget.token.name ?? '');
    }
  }

  Widget transactionButton(BuildContext context) {
    String titleText = 'confirm';
    AxsButtonType type = AxsButtonType.primary;

    switch (processType) {
      case TransactionProcessType.confirm:
        titleText = 'confirm';
        break;
      case TransactionProcessType.send:
        titleText = 'send';
        break;
      case TransactionProcessType.sending:
        titleText = 'sending';
        break;
      default:
        titleText = 'done';
        type = AxsButtonType.pass;
        break;
    }

    void goToNext() {
      setState(() {
        index += 1;
        processType = TransactionProcessType.values[index];
      });
    }

    return MxcButton.primary(
      key: const ValueKey('transactionButton'),
      size: AxsButtonSize.xl,
      title: FlutterI18n.translate(context, titleText),
      type: type,
      onTap: () async {
        if (processType != TransactionProcessType.done) {
          goToNext();
          if (processType == TransactionProcessType.sending) {
            final res = await widget.onTap(processType);
            if (res != null) {
              goToNext();
            }
          }
        } else {
          widget.onTap(processType);
        }
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
              MXCFormatter.formatNumberForUI(
                widget.amount,
              ),
              style: FontTheme.of(context).h5(),
            ),
            const SizedBox(width: 4),
            Text(
              widget.token.symbol ?? '--',
              style: FontTheme.of(context).h5.secondary(),
            ),
            const SizedBox(height: 4),
          ],
        )
      ],
    );
  }
}
