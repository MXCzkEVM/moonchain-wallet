import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:mxc_logic/mxc_logic.dart';
import './utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

export 'domain/transactions_history_use_case.dart';
export 'domain/transactions_history_repository.dart';

class RecentTransactions extends HookConsumerWidget {
  const RecentTransactions(
      {super.key,
      this.walletAddress,
      this.transactions,
      required this.tokens,
      this.networkType,
      this.nlySix});

  final String? walletAddress;
  final List<TransactionModel>? transactions;
  final List<Token> tokens;
  final NetworkType? networkType;
  final bool? nlySix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    return Column(
      children: [
        transactions != null && transactions!.isEmpty
            ? Center(
                child: Text(
                  FlutterI18n.translate(context, 'no_transactions_yet'),
                  style: FontTheme.of(context)
                      .body2()
                      .copyWith(color: ColorsTheme.of(context).textGrey2),
                ),
              )
            : GreyContainer(
                child: walletAddress == null || transactions == null
                    ? const SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ))
                    : Column(
                        children: [
                          ...RecentTransactionsUtils.generateTx(
                              walletAddress!, transactions!, tokens, nlySix)
                        ],
                      )),
        const SizedBox(
          height: Sizes.spaceSmall,
        ),
        MxcChipButton(
            key: const Key('viewOtherTransactions'),
            title: FlutterI18n.translate(context, 'view_other_transactions'),
            iconData: MxcIcons.external_link,
            alignIconStart: false,
            onTap: () => presenter.getViewOtherTransactionsLink()),
      ],
    );
  }
}
