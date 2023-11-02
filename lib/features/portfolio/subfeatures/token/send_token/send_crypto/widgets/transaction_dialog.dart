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
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
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
      child: TransactionInfo(
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
    ),
  );
}
