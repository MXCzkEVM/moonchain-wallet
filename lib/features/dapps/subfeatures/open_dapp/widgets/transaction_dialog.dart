import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_info.dart';

Future<bool?> showTransactionDialog(BuildContext context,
    {String? title,
    required String amount,
    required String from,
    required String to,
    required String estimatedFee,
    required String maxFee,
    VoidCallback? onTap,
    required String symbol}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
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
            titleText: title ?? '',
            action: Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
          TransactionInfo(
            amount: amount,
            from: from,
            to: to,
            estimatedFee: estimatedFee,
            maxFee: maxFee,
            onTap: onTap,
            symbol: symbol,
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
