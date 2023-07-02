import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/home/presentation/home_tab/home_tab_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:intl/intl.dart';

enum TransactionType { send, receive }

enum TransactionStatus { done, pending, failed }

class RecentTransactions extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeTabContainer.actions);
    final state = ref.watch(homeTabContainer.state);

    return GreyContainer(
        padding: const EdgeInsets.all(10),
        child: state.txList == null
            ? Container()
            : ListView.builder(
                itemCount: state.txList!.items!.length - 1,
                itemBuilder: (context, index) {
                  final currentTx = state.txList!.items![index];
                  String amount = '0';
                  String symbol = 'MXC';
                  String timeStamp = 'Unknown';
                  String hash = currentTx.hash ?? 'Unknown';
                  TransactionType transactionType = TransactionType.send;
                  TransactionStatus transactionStatus =
                      TransactionStatus.failed;
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
                    timeStamp = '${time.month}/${time.day}/${time.year}';
                    transactionType = checkForTransactionType(
                        state.walletAddress!.hex,
                        currentTx.from!.hash!.toLowerCase());
                    amount = Formatter.convertWeiToEth(currentTx.value ?? '0');

                    if (currentTx.txTypes!.contains('contract_call')) {
                      if (state.defaultTokens.tokens != null) {
                        final tokenIndex = state.defaultTokens.tokens!
                            .indexWhere((element) =>
                                element.address ==
                                (currentTx.from!.isContract!
                                    ? currentTx.from!.hash!
                                    : currentTx.to!.hash!));
                        logoUrl =
                            state.defaultTokens.tokens![tokenIndex].logoUri!;
                      }
                    }
                  } else if (currentTx.txTypes != null &&
                      currentTx.txTypes!.contains('coin_transfer')) {
                    timeStamp =
                        '${currentTx.timestamp!.month}/${currentTx.timestamp!.day}/${currentTx.timestamp!.year}';
                    transactionType = checkForTransactionType(
                        state.walletAddress!.hex,
                        currentTx.from!.hash!.toLowerCase());
                    amount = Formatter.convertWeiToEth(currentTx.value ?? '0');
                  } else if (currentTx.txTypes == null &&
                      currentTx.tokenTransfers != null &&
                      currentTx.tokenTransfers![0].type == 'token_transfer') {
                    symbol = currentTx.tokenTransfers![0].token!.name!;

                    if (currentTx.tokenTransfers![0].token!.name != null) {
                      if (state.defaultTokens.tokens != null) {
                        final tokenIndex = state.defaultTokens.tokens!
                            .indexWhere((element) =>
                                element.address ==
                                currentTx.tokenTransfers![0].token!.address!);
                        logoUrl =
                            state.defaultTokens.tokens![tokenIndex].logoUri!;
                      }
                    }
                    timeStamp =
                        '${currentTx.tokenTransfers![0].timestamp!.month}/${currentTx.tokenTransfers![0].timestamp!.day}/${currentTx.tokenTransfers![0].timestamp!.year}';
                    amount = Formatter.convertWeiToEth(
                        currentTx.tokenTransfers![0].total!.value ?? '0');
                    hash = currentTx.tokenTransfers![0].txHash ?? "Unknown";
                    transactionType = checkForTransactionType(
                      state.walletAddress!.hex,
                      currentTx.tokenTransfers![0].from!.hash!.toLowerCase(),
                    );
                  }

                  return RecentTrxListItem(
                    logoUrl: logoUrl,
                    amount: double.parse(amount),
                    symbol: symbol,
                    timestamp: timeStamp,
                    txHash: hash,
                    transactionType: transactionType,
                  );
                },
              ));
  }

  TransactionType checkForTransactionType(
      String userAddress, String currentTxFromHash) {
    if (currentTxFromHash == userAddress) {
      return TransactionType.send;
    } else {
      return TransactionType.receive;
    }
  }

  TransactionStatus checkForTransactionStatus(String result, String status) {
    if (result == 'pending') {
      return TransactionStatus.pending;
    } else if (status == 'error') {
      return TransactionStatus.failed;
    } else {
      return TransactionStatus.done;
    }
  }
}

class RecentTrxListItem extends StatelessWidget {
  final double amount;
  final String symbol;
  final String txHash;
  final String timestamp;
  final TransactionType transactionType;
  final String logoUrl;
  const RecentTrxListItem(
      {Key? key,
      required this.logoUrl,
      required this.amount,
      required this.symbol,
      required this.txHash,
      required this.timestamp,
      required this.transactionType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTXHash = Formatter.formatWalletAddress(txHash);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                    height: 25, width: 25, child: SvgPicture.network(logoUrl)),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$amount $symbol',
                        style: FontTheme.of(context)
                            .caption1()
                            .copyWith(overflow: TextOverflow.ellipsis),
                        softWrap: true,
                      ),
                    ),
                    Text(
                      '${FlutterI18n.translate(context, 'tx')} $formattedTXHash',
                      style: FontTheme.of(context).caption1(),
                    )
                  ],
                ),
              ],
            ),
            Text(
              FlutterI18n.translate(context, transactionType.name),
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: getTransactionTypeColor(context, transactionType)),
            ),
            Text(
              FlutterI18n.translate(context, 'date'),
              style: FontTheme.of(context)
                  .h7()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            Text(
              timestamp,
              style: FontTheme.of(context)
                  .h7()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}

Color getTransactionTypeColor(
    BuildContext context, TransactionType transactionType) {
  late Color txColor;
  switch (transactionType) {
    case TransactionType.send:
      txColor = ColorsTheme.of(context).mainRed;
      break;
    case TransactionType.receive:
      txColor = ColorsTheme.of(context).green;
      break;
    default:
      txColor = Colors.amber;
  }
  return txColor;
}
