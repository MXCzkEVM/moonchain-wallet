import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:mxc_logic/mxc_logic.dart';
import './transaction_status_chip.dart';
import './transaction_type_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import '../../../common.dart';
import '../utils.dart';

class RecentTrxListItem extends HookConsumerWidget {
  final String? amount;
  final String? symbol;
  final String txHash;
  final String timestamp;
  final TransactionType transactionType;
  final TransactionStatus transactionStatus;
  final String logoUrl;
  const RecentTrxListItem(
      {Key? key,
      required this.logoUrl,
      required this.amount,
      required this.symbol,
      required this.txHash,
      required this.timestamp,
      required this.transactionType,
      required this.transactionStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    final formattedTXHash = Formatter.formatWalletAddress(txHash);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(6.55),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsTheme.of(context).primaryBackground),
                    child: logoUrl.contains('https')
                        ? SvgPicture.network(
                            logoUrl,
                            height: 24,
                            width: 24,
                          )
                        : SvgPicture.asset(
                            logoUrl,
                            height: 24,
                            width: 24,
                          )),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionTypeWidget(
                          transactionStatusChip:
                              transactionStatus == TransactionStatus.done
                                  ? Container()
                                  : TransactionStatusChip(
                                      color: RecentTransactionsUtils
                                          .getTransactionStatusColor(
                                              context, transactionStatus),
                                      title: transactionStatus.name),
                          transactionType: transactionType.name,
                          transactionTypeColor:
                              RecentTransactionsUtils.getTransactionTypeColor(
                                  context, transactionType),
                          transactionTypeIcon:
                              RecentTransactionsUtils.getTransactionTypeIcon(
                                  transactionType)),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          if (amount != null)
                            Text(
                              amount!,
                              style: FontTheme.of(context)
                                  .body1
                                  .primary()
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    foreground: state.hideBalance == true
                                        ? (Paint()
                                          ..style = PaintingStyle.fill
                                          ..color = Colors.white
                                          ..maskFilter = const MaskFilter.blur(
                                              BlurStyle.normal, 6))
                                        : null,
                                  ),
                              softWrap: true,
                            ),
                          const SizedBox(
                            width: 4,
                          ),
                          if (symbol != null)
                            Expanded(
                              child: Text(
                                symbol!,
                                style: FontTheme.of(context).h7().copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          ColorsTheme.of(context).textSecondary,
                                    ),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timestamp,
                style: FontTheme.of(context).h7().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorsTheme.of(context).textGrey2),
              ),
              const SizedBox(
                width: 4,
              ),
              GestureDetector(
                onTap: () {
                  presenter.viewTransaction(txHash);
                },
                child: Row(
                  children: [
                    Text(
                      FlutterI18n.translate(context, 'tx'),
                      style: FontTheme.of(context).caption1().copyWith(
                          fontSize: 14,
                          color: ColorsTheme.of(context).textSecondary),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      formattedTXHash,
                      style: FontTheme.of(context).caption1().copyWith(
                          fontSize: 14,
                          color: ColorsTheme.of(context).textSecondary),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Icon(
                      MxcIcons.external_link,
                      size: 20,
                      color: ColorsTheme.of(context).iconSecondary,
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
