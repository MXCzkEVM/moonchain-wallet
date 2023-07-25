import 'package:datadashwallet/common/components/recent_transactions/widgets/recent_transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import '../../mxc_icons.dart';
import '../../utils/formatter.dart';
import 'recent_transactions.dart';

class RecentTransactionsUtils {
  static TransactionType checkForTransactionType(
      String userAddress, String currentTxFromHash) {
    if (currentTxFromHash == userAddress) {
      return TransactionType.sent;
    } else {
      return TransactionType.received;
    }
  }

  static TransactionStatus checkForTransactionStatus(
      String result, String status) {
    if (result == 'pending') {
      return TransactionStatus.pending;
    } else if (status == 'error') {
      return TransactionStatus.failed;
    } else {
      return TransactionStatus.done;
    }
  }

  static Color getTransactionTypeColor(
      BuildContext context, TransactionType transactionType) {
    late Color txColor;
    switch (transactionType) {
      case TransactionType.sent:
        txColor = ColorsTheme.of(context).mainRed;
        break;
      case TransactionType.received:
        txColor = ColorsTheme.of(context).greenMain;
        break;
      default:
        txColor = ColorsTheme.of(context).mainRed;
    }
    return txColor;
  }

  static IconData getTransactionTypeIcon(TransactionType transactionType) {
    late IconData txIcon;
    switch (transactionType) {
      case TransactionType.sent:
        txIcon = MXCIcons.send;
        break;
      case TransactionType.received:
        txIcon = MXCIcons.receive;
        break;
      default:
        txIcon = Icons.question_mark;
    }
    return txIcon;
  }

  static Color getTransactionStatusColor(
      BuildContext context, TransactionStatus transactionStatus) {
    late Color txColor;
    switch (transactionStatus) {
      case TransactionStatus.pending:
        txColor = ColorsTheme.of(context).textOrange;
        break;
      case TransactionStatus.failed:
        txColor = ColorsTheme.of(context).mainRed;
        break;
      default:
        txColor = ColorsTheme.of(context).mainRed;
    }
    return txColor;
  }

  static List<RecentTrxListItem> generateTx(String walletAddressHash,
      List<WannseeTransactionModel> items, List<Token> tokensList) {
    List<RecentTrxListItem> widgets = [];

    for (int i = 0; i < (items.length > 6 ? 6 : items.length); i++) {
      final currentTx = items[i];
      String amount = '0';
      String symbol = 'Unknown';
      String timeStamp = 'Unknown';
      String hash = currentTx.hash ?? 'Unknown';
      TransactionType transactionType = TransactionType.sent;
      TransactionStatus transactionStatus = TransactionStatus.done;
      String logoUrl =
          'https://raw.githubusercontent.com/MXCzkEVM/wannseeswap-tokenlist/main/assets/mxc.svg';

      // two type of tx : coin_transfer from filtered tx list & token transfer from token transfer list
      // If not 'contract_call' or 'coin_transfer' then empty and that means failed in other words
      // another tx that we have are : pending coin transfer (which is received on both sides) &
      // pending token transfer (which is only received on the sender side)
      if (currentTx.result == 'pending') {
        // could be contract_call || coin_transfer
        transactionStatus = TransactionStatus.pending;
        final time = DateTime.now();
        timeStamp = Formatter.localTime(time);

        transactionType = RecentTransactionsUtils.checkForTransactionType(
            walletAddressHash, currentTx.from!.hash!.toLowerCase());
        amount = Formatter.convertWeiToEth(currentTx.value ?? '0');

        if (currentTx.txTypes!.contains('contract_call')) {
          if (tokensList != null) {
            final tokenIndex = tokensList.indexWhere((element) =>
                element.address ==
                (currentTx.from!.isContract!
                    ? currentTx.from!.hash!
                    : currentTx.to!.hash!));
            logoUrl = tokensList[tokenIndex].logoUri!;
          }
        }
      } else if (currentTx.txTypes != null &&
          currentTx.txTypes!.contains('coin_transfer')) {
        logoUrl =
            'https://raw.githubusercontent.com/MXCzkEVM/wannseeswap-tokenlist/main/assets/mxc.svg';
        symbol = 'MXC';
        timeStamp = Formatter.localTime(currentTx.timestamp!);

        transactionType = RecentTransactionsUtils.checkForTransactionType(
            walletAddressHash, currentTx.from!.hash!.toLowerCase());
        amount = Formatter.convertWeiToEth(currentTx.value ?? '0');
      } else if (currentTx.txTypes == null &&
          currentTx.tokenTransfers != null &&
          currentTx.tokenTransfers![0].type == 'token_transfer') {
        symbol = currentTx.tokenTransfers![0].token!.name!;

        if (currentTx.tokenTransfers![0].token!.name != null) {
          final tokenIndex = tokensList.indexWhere((element) =>
              element.address == currentTx.tokenTransfers![0].token!.address!);
          if (tokenIndex != -1) {
            logoUrl = tokensList[tokenIndex].logoUri!;
          }
        }

        timeStamp =
            Formatter.localTime(currentTx.tokenTransfers![0].timestamp!);

        amount = Formatter.convertWeiToEth(
            currentTx.tokenTransfers![0].total!.value ?? '0');
        hash = currentTx.tokenTransfers![0].txHash ?? "Unknown";
        transactionType = RecentTransactionsUtils.checkForTransactionType(
          walletAddressHash,
          currentTx.tokenTransfers![0].from!.hash!.toLowerCase(),
        );
      }

      widgets.add(RecentTrxListItem(
        logoUrl: logoUrl,
        amount: amount,
        symbol: symbol,
        timestamp: timeStamp,
        txHash: hash,
        transactionType: transactionType,
        transactionStatus: transactionStatus,
      ));
    }
    return widgets;
  }
}
