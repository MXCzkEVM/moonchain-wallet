import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:datadashwallet/features/wallet/presentation/widgets/tweets_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'wallet_page_presenter.dart';

class WalletPage extends HookConsumerWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    final List<TransactionModel>? txList = state.txList == null
        ? null
        : state.txList!.length > 6
            ? state.txList!.sublist(0, 6)
            : state.txList!;

    return MxcPage(
        useAppBar: true,
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).screenBackground,
        layout: LayoutType.column,
        useContentPadding: false,
        appBar: AppNavBar(
          leading: IconButton(
            key: const ValueKey('settingsButton'),
            icon: const Icon(MxcIcons.settings, size: 32),
            onPressed: () {
              Navigator.of(context).push(
                route(
                  const SettingsPage(),
                ),
              );
            },
            color: ColorsTheme.of(context).iconPrimary,
          ),
          action: IconButton(
            key: const ValueKey('appsButton'),
            icon: const Icon(MxcIcons.apps, size: 32),
            onPressed: () =>
                Navigator.of(context).replaceAll(route(const DAppsPage())),
            color: ColorsTheme.of(context).iconPrimary,
          ),
        ),
        children: [
          Expanded(
              child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, right: 24, left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FlutterI18n.translate(context, 'wallet'),
                      style: FontTheme.of(context).h4().copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                            color: ColorsTheme.of(context).textPrimary,
                          ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const BalancePanel(false),
                    const SizedBox(
                      height: 32,
                    ),
                    Text(FlutterI18n.translate(context, 'transaction_history'),
                        style: FontTheme.of(context).h7().copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: ColorsTheme.of(context).textSecondary)),
                    const SizedBox(
                      height: 12,
                    ),
                    RecentTransactions(
                      walletAddress: state.account?.address,
                      transactions: txList,
                      tokens: state.tokensList,
                      networkType: state.network?.networkType,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const TweetsList()
                  ],
                ),
              ),
            ],
          ))
        ]);
  }
}
