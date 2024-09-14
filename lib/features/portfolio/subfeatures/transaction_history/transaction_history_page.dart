import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_history_presenter.dart';
import 'transaction_history_state.dart';

class TransactionHistoryPage extends HookConsumerWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  ProviderBase<TransactionHistoryPresenter> get presenter =>
      transactionHistoryPageContainer.actions;

  @override
  ProviderBase<TransactionHistoryState> get state =>
      transactionHistoryPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      onRefresh: () => ref.read(presenter).loadPage(),
      useGradientBackground: true,
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        action: IconButton(
          key: const ValueKey('appsButton'),
          icon: const Icon(MxcIcons.apps),
          iconSize: 32,
          onPressed: () =>
              Navigator.of(context).replaceAll(route(const DAppsPage())),
          color: ColorsTheme.of(context).iconPrimary,
        ),
      ),
      children: [
        Text(
          translate('transactions'),
          style: FontTheme.of(context).h4(),
        ),
        const SizedBox(height: 12),
        Container(
          alignment: Alignment.centerRight,
          child: MxcChipButton(
            key: const Key('filterAndSortButton'),
            onTap: () => ref.read(presenter).fliterAndSort(),
            title: FlutterI18n.translate(context, 'filter_&_sort'),
            alignIconStart: true,
            iconData: MxcIcons.filter,
          ),
        ),
        const SizedBox(height: 12),
        RecentTransactions(
          walletAddress: ref.watch(state).account!.address,
          transactions: ref.watch(state).filterTransactions,
          tokens: ref.watch(state).tokens,
          networkType: ref.watch(state).network?.networkType,
        ),
      ],
    );
  }
}
