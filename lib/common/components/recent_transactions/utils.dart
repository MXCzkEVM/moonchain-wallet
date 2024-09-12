import 'package:moonchain_wallet/common/components/recent_transactions/widgets/recent_transaction_item.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class RecentTransactionsUtils {
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
        txColor = ColorsTheme.of(context).saturatedRed;
        break;
      case TransactionType.received:
        txColor = ColorsTheme.of(context).greenMain;
        break;
      case TransactionType.contractCall:
        txColor = ColorsTheme.of(context).textGrey1;
        break;
      default:
        txColor = ColorsTheme.of(context).saturatedRed;
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
        txColor = ColorsTheme.of(context).saturatedRed;
        break;
      default:
        txColor = ColorsTheme.of(context).saturatedRed;
    }
    return txColor;
  }

  static List<RecentTrxListItem> generateTx(String walletAddressHash,
      List<TransactionModel> items, List<Token> tokensList, bool? onlySix) {
    if ((onlySix ?? false) && items.length > 6) {
      items = items.sublist(0, 6);
    }
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
            : MXCFormatter.convertWeiToEth(e.value!, decimal),
        symbol: symbol,
        timestamp: e.timeStamp == null
            ? "Unknown"
            : MXCFormatter.localTime(e.timeStamp!),
        txHash: e.hash,
        transactionType: e.type,
        transactionStatus: e.status,
        transactionAction: e.action,
        transaction: e,
        shouldShowActionButtons: onlySix ?? false,
      );
    }).toList();
  }

  static Widget getActionButton(TransactionActions? action,
      VoidCallback cancelFunction, VoidCallback speedUpFunction) {
    switch (action) {
      case null:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcChipButton(
              key: const Key('cancelButton'),
              onTap: () => cancelFunction(),
              title: 'Cancel',
              buttonState: ChipButtonStates.inactiveState,
            ),
            const SizedBox(
              width: Sizes.space2XSmall,
            ),
            MxcChipButton(
              key: const Key('speedUpButton'),
              onTap: () => speedUpFunction(),
              title: 'Speed up',
              buttonState: ChipButtonStates.activeState,
            ),
          ],
        );
      case TransactionActions.cancel:
        return MxcChipButton(
          key: const Key('speedUpCancellationButton'),
          onTap: () => speedUpFunction(),
          title: 'Speed up this cancellation',
          buttonState: ChipButtonStates.activeState,
        );
      case TransactionActions.speedUp:
        return MxcChipButton(
          key: const Key('cancelButton'),
          onTap: () => cancelFunction(),
          title: 'Cancel',
          buttonState: ChipButtonStates.inactiveState,
        );
      case TransactionActions.cancelSpeedUp:
        return Container();
      case TransactionActions.speedUpCancel:
        return MxcChipButton(
          key: const Key('speedUpCancellationButton'),
          onTap: () => speedUpFunction(),
          title: 'Speed up this cancellation',
          buttonState: ChipButtonStates.activeState,
        );
    }
  }
}
