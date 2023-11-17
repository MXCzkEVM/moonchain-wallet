import 'package:datadashwallet/common/components/recent_transactions/widgets/recent_transaction_item.dart';
import 'package:mxc_logic/mxc_logic.dart';
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
      case TransactionType.contractCall:
        txColor = ColorsTheme.of(context).textGrey1;
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
      case TransactionType.contractCall:
        txIcon = Icons.article_rounded;
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
      List<TransactionModel> items, List<Token> tokensList) {
    return items.map((e) {
      final foundToken = tokensList.firstWhere(
          (element) => element.address == e.token.address,
          orElse: () => Token());
      final logoUrl = foundToken.logoUri ??
          e.token.logoUri ??
          'assets/svg/networks/unknown.svg';
      final decimal =
          foundToken.decimals ?? e.token.decimals ?? Config.ethDecimals;
      final symbol = foundToken.symbol ?? e.token.symbol;

      return RecentTrxListItem(
        logoUrl: logoUrl,
        amount: e.value == null
            ? null
            : Formatter.convertWeiToEth(e.value!, decimal),
        symbol: symbol,
        timestamp:
            e.timeStamp == null ? "Unknown" : Formatter.localTime(e.timeStamp!),
        txHash: e.hash,
        transactionType: e.type,
        transactionStatus: e.status,
      );
    }).toList();
  }
}
