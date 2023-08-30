import 'package:datadashwallet/common/components/recent_transactions/widgets/recent_transaction_item.dart';
import 'package:datadashwallet/common/config.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
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
        txIcon = MxcIcons.send;
        break;
      case TransactionType.received:
        txIcon = MxcIcons.receive;
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

    for (int i = 0; i < items.length; i++) {
      final currentTx = items[i];
      String amount = '0';
      String symbol = 'Unknown';
      String timeStamp = 'Unknown';
      String hash = currentTx.hash ?? 'Unknown';
      TransactionType transactionType = TransactionType.sent;
      TransactionStatus transactionStatus = TransactionStatus.done;
      String logoUrl = 'assets/svg/networks/unknown.svg';

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
        amount = Formatter.convertWeiToEth(
            currentTx.value ?? '0', Config.ethDecimals);
        logoUrl = Config.mxcLogoUri;
        symbol = Config.mxcName;
      } else if (currentTx.txTypes != null &&
          currentTx.txTypes!.contains('coin_transfer')) {
        logoUrl = Config.mxcLogoUri;
        symbol = Config.mxcSymbol;
        timeStamp = Formatter.localTime(currentTx.timestamp!);

        transactionType = RecentTransactionsUtils.checkForTransactionType(
            walletAddressHash, currentTx.from!.hash!.toLowerCase());
        amount = Formatter.convertWeiToEth(
            currentTx.value ?? '0', Config.ethDecimals);
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
            currentTx.tokenTransfers![0].total!.value ?? '0',
            Config.ethDecimals);
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

  static String getViewOtherTransactionsLink(
      NetworkType networkType, String walletAddress) {
    String baseUrl = 'explorer.mxc.com';

    if (networkType == NetworkType.testnet) {
      baseUrl = 'wannsee-explorer.mxc.com';
    }

    return 'https://$baseUrl/address/$walletAddress';
  }
}
