import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_info.dart';

Future<bool?> showTransactionDialog(BuildContext context,
    {String? title = '',
    required String amount,
    required String from,
    required String to,
    required String estimatedFee,
    required String maxFee,
    VoidCallback? onTap,
    required String symbol}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: false,
    widgets: [
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
  );
}
