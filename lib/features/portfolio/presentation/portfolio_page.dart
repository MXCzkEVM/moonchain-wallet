import 'dart:ui';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nft/choose_nft/choose_nft_page.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nft/nft_list/nft_list.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/tokens_balance_list/tokens_balance_list.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/transaction_history/transaction_history_page.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/send_token/choose_crypto/choose_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'portfolio_page_presenter.dart';

class PortfolioPage extends HookConsumerWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(portfolioContainer.actions);
    final state = ref.watch(portfolioContainer.state);

    return MxcPage(
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).screenBackground,
        layout: LayoutType.column,
        useContentPadding: false,
        childrenPadding: const EdgeInsets.only(top: 25, right: 24, left: 24),
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
        floatingActionButton: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: IntrinsicHeight(
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        // width: 100,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: ColorsTheme.of(context).grey4),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          color:
                              ColorsTheme.of(context).white.withOpacity(0.02),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MxcCircleButton.icon(
                          key: const Key('sendButton'),
                          icon: MxcIcons.send,
                          iconFillColor: ColorsTheme.of(context)
                              .iconButtonBackgroundActive,
                          color: ColorsTheme.of(context).iconButtonInvertActive,
                          onTap: () => Navigator.of(context).push(route(
                              state.switchTokensOrNFTs
                                  ? const ChooseCryptoPage()
                                  : const ChooseNftPage())),
                          titleStyle: FontTheme.of(context).subtitle1.primary(),
                          iconSize: 24,
                          filled: false,
                          shadowRadius: 50,
                          title: FlutterI18n.translate(context, 'send'),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        MxcCircleButton.icon(
                          key: const Key('receiveButton'),
                          iconFillColor: ColorsTheme.of(context)
                              .iconButtonBackgroundActive,
                          color: ColorsTheme.of(context).iconButtonInvertActive,
                          icon: MxcIcons.receive,
                          onTap: () => presenter.showReceiveSheet(),
                          titleStyle: FontTheme.of(context).subtitle1.primary(),
                          iconSize: 24,
                          filled: false,
                          shadowRadius: 50,
                          title: FlutterI18n.translate(context, 'receive'),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        MxcCircleButton.icon(
                          key: const Key('historyButton'),
                          iconFillColor: ColorsTheme.of(context)
                              .iconButtonBackgroundActive,
                          color: ColorsTheme.of(context).iconButtonInvertActive,
                          icon: MxcIcons.history,
                          onTap: () => Navigator.of(context)
                              .push(route(const TransactionHistoryPage())),
                          titleStyle: FontTheme.of(context).subtitle1.primary(),
                          iconSize: 24,
                          filled: false,
                          shadowRadius: 50,
                          title: FlutterI18n.translate(context, 'history'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        children: [
          Expanded(
              child: ListView(
            padding: const EdgeInsets.only(bottom: 160),
            children: [
              Text(FlutterI18n.translate(context, 'portfolio'),
                  style: FontTheme.of(context).h4().copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: ColorsTheme.of(context).textPrimary)),
              const SizedBox(
                height: 6,
              ),
              const BalancePanel(true),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  MxcChipButton(
                    key: const Key('tokensTabButton'),
                    buttonState: state.switchTokensOrNFTs
                        ? ChipButtonStates.activeState
                        : ChipButtonStates.inactiveState,
                    onTap: () => presenter.changeTokensOrNFTsTab(true),
                    title: FlutterI18n.translate(context, 'tokens'),
                    alignIconStart: true,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MxcChipButton(
                    key: const Key('nftsTabButton'),
                    buttonState: !state.switchTokensOrNFTs
                        ? ChipButtonStates.activeState
                        : ChipButtonStates.inactiveState,
                    onTap: () => presenter.changeTokensOrNFTsTab(false),
                    title: FlutterI18n.translate(context, 'nfts'),
                    alignIconStart: true,
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (state.switchTokensOrNFTs) ...[
                const TokensBalanceList(),
              ] else ...[
                NFTList(
                  nfts: state.nftList,
                ),
              ]
            ],
          ))
        ]);
  }
}
