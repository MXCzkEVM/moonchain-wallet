import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/wallet/presentation/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'wallet_page_presenter.dart';
import 'wallet_page_state.dart';

class WalletPage extends HookConsumerWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);

    return MxcPage(
        useAppBar: true,
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).screenBackground,
        layout: LayoutType.column,
        useContentPadding: false,
        childrenPadding: const EdgeInsets.only(top: 24, right: 24, left: 24),
        appBar: AppNavBar(
          leading: IconButton(
            key: const ValueKey('menusButton'),
            icon: const Icon(MXCIcons.burger_menu, size: 32),
            onPressed: () {},
            color: ColorsTheme.of(context).primaryButton,
          ),
          action: IconButton(
            key: const ValueKey('appsButton'),
            icon: const Icon(MXCIcons.apps, size: 32),
            onPressed: () =>
                Navigator.of(context).replaceAll(route(const DAppsPage())),
            color: ColorsTheme.of(context).primaryButton,
          ),
        ),
        children: [
          Expanded(
              child: ListView(
            children: [
              Text(FlutterI18n.translate(context, 'wallet'),
                  style: FontTheme.of(context).h4().copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: ColorsTheme.of(context).textPrimary)),
              const SizedBox(
                height: 6,
              ),
              const BalancePanel(false),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, 'transaction_history'),
                      style: FontTheme.of(context).h7().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorsTheme.of(context).textSecondary)),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              RecentTransactions(
                walletAddress: state.walletAddress,
                transactions: state.txList?.items,
                tokens: state.tokensList,
              ),
              const SizedBox(
                height: 32,
              ),
              const WalletSlider(),
            ],
          ))
        ]);
  }
}
