import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:mxc_logic/mxc_logic.dart';
import './utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum TransactionType { sent, received, all }

enum TransactionStatus { done, pending, failed }

class RecentTransactions extends HookConsumerWidget {
  const RecentTransactions({
    super.key,
    this.walletAddress,
    this.transactions,
    required this.tokens,
    this.networkType,
  });

  final String? walletAddress;
  final List<WannseeTransactionModel>? transactions;
  final List<Token> tokens;
  final NetworkType? networkType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return transactions != null && transactions!.isEmpty
        ? Center(
            child: Text(
              FlutterI18n.translate(context, 'no_transactions_yet'),
              style: FontTheme.of(context).body2(),
            ),
          )
        : Column(
            children: [
              GreyContainer(
                  child: walletAddress == null || transactions == null
                      ? const SizedBox(
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ))
                      : Column(
                          children: [
                            ...RecentTransactionsUtils.generateTx(
                              walletAddress!,
                              transactions!,
                              tokens,
                            )
                          ],
                        )),
              const SizedBox(
                height: 12,
              ),
              if (transactions != null)
                MxcChipButton(
                  key: const Key('viewOtherTransactions'),
                  title:
                      FlutterI18n.translate(context, 'view_other_transactions'),
                  iconData: MxcIcons.external_link,
                  alignIconStart: false,
                  onTap: () => Navigator.of(context).push(
                    route.featureDialog(
                      maintainState: false,
                      OpenAppPage(
                        url: RecentTransactionsUtils
                            .getViewOtherTransactionsLink(
                                networkType!, walletAddress!),
                      ),
                    ),
                  ),
                ),
            ],
          );
  }
}
