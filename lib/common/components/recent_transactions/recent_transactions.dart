import 'package:datadashwallet/common/common.dart';
import './utils.dart';
import 'package:datadashwallet/features/home/home/home_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum TransactionType { sent, received }

enum TransactionStatus { done, pending, failed }

class RecentTransactions extends HookConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);

    return state.txList != null && state.txList!.items!.isEmpty
        ? Center(
            child: Text(
              FlutterI18n.translate(context, 'no_transactions_yet'),
              style: FontTheme.of(context).h6().copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
            ),
          )
        : Column(
            children: [
              GreyContainer(
                  child: state.txList == null
                      ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : Column(
                          children: [
                            ...RecentTransactionsUtils.generateTx(
                                state.txList!.items!,
                                state.walletAddress!,
                                state.tokensList)
                          ],
                        )),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  const Spacer(),
                  MxcChipButton(
                    key: const Key('viewOtherTransactions'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onTap: () {
                      presenter.viewMoreTransactions();
                    },
                    title:
                        '${FlutterI18n.translate(context, 'view_other_transactions')}  ',
                    iconData: MXCIcons.external_link,
                    alignIconStart: false,
                  ),
                  const Spacer()
                ],
              ),
            ],
          );
  }
}
