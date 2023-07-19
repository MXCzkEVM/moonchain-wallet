import './transaction_status_chip.dart';
import './transaction_type_widget.dart';
import 'package:datadashwallet/features/home/home/home_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import '../../../common.dart';
import '../utils.dart';

class RecentTrxListItem extends HookConsumerWidget {
  final double amount;
  final String symbol;
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
    final presenter = ref.read(homeContainer.actions);
    final formattedTXHash = Formatter.formatWalletAddress(txHash);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(6.55),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsTheme.of(context).primaryBackground),
                  child: SvgPicture.network(
                    logoUrl,
                    height: 24,
                    width: 24,
                  )),
              const SizedBox(
                width: 8,
              ),
              Column(
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
                      Text(
                        amount.toString(),
                        style: FontTheme.of(context).body2.primary(),
                        softWrap: true,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          symbol,
                          style: FontTheme.of(context).h7().copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              color: ColorsTheme.of(context).textSecondary),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
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
                      MXCIcons.external_link,
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
