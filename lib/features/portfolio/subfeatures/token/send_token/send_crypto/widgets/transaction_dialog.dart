import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_info.dart';

enum TransactionProcessType { confirm, send, sending, done }

Future<bool?> showTransactionDialog(
  BuildContext context, {
  required String amount,
  required String balance,
  required Token token,
  required String network,
  required String networkSymbol,
  required String from,
  required String to,
  required String estimatedFee,
  required String maxFee,
  TransactionProcessType? processType,
  required Function(TransactionProcessType) onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    content: TransactionInfo(
      amount: amount,
      balance: balance,
      token: token,
      network: network,
      networkSymbol: networkSymbol,
      from: from,
      to: to,
      estimatedFee: estimatedFee,
      maxFee: maxFee,
      processType: processType,
      onTap: onTap,
    ),
  );
}
