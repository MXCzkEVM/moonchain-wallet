import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_info.dart';

enum TransactionProcessType { confirm, send, done }

Future<bool?> showTransactionDialog(BuildContext context,
    {String? title = '',
    required Nft nft,
    required String newtork,
    required String from,
    required String to,
    String? estimatedFee,
    TransactionProcessType? processType,
    VoidCallback? onTap,
    required String symbol}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: false,
    widgets: [
      TransactionInfo(
        nft: nft,
        newtork: newtork,
        from: from,
        to: to,
        estimatedFee: estimatedFee,
        processType: processType,
        onTap: onTap,
        symbol: symbol,
      ),
      const SizedBox(height: 10),
    ],
  );
}
