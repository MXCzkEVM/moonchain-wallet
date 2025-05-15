import 'dart:ui';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/choose_nft/choose_nft_page.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/nft_list.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/tokens_balance_list/tokens_balance_list.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/transaction_history/transaction_history_page.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/token/send_token/choose_crypto/choose_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/common/common.dart';
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
      useGradientBackground: true,
      layout: LayoutType.column,
      useContentPadding: false,
      childrenPadding: const EdgeInsets.only(top: 25, right: 12, left: 12),
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
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                onTap: () =>
                                    presenter.changeTokensOrNFTsTab(true),
                                title: FlutterI18n.translate(context, 'tokens'),
                                alignIconStart: true,
                                mxcChipsEdgeType: MXCChipsEdgeType.hard,
                                primaryColor: Colors.white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              MxcChipButton(
                                key: const Key('nftsTabButton'),
                                buttonState: !state.switchTokensOrNFTs
                                    ? ChipButtonStates.activeState
                                    : ChipButtonStates.inactiveState,
                                onTap: () =>
                                    presenter.changeTokensOrNFTsTab(false),
                                title: FlutterI18n.translate(context, 'nfts'),
                                alignIconStart: true,
                                mxcChipsEdgeType: MXCChipsEdgeType.hard,
                                primaryColor: Colors.white,
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
                      ),
                    ),
                  ),
                ],
              ),
              // Overlay on top of the column layout
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: ColorsTheme.of(context).white),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        color: ColorsTheme.of(context).white.withOpacity(0.02),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MXCRectangleButton.icon(
                            key: const Key('sendButton'),
                            icon: MxcIcons.send,
                            iconFillColor: Colors.white,
                            color:
                                ColorsTheme.of(context).iconButtonInvertActive,
                            onTap: () => Navigator.of(context).push(route(
                                state.switchTokensOrNFTs
                                    ? const ChooseCryptoPage()
                                    : const ChooseNftPage())),
                            titleStyle:
                                FontTheme.of(context).subtitle1.primary(),
                            iconSize: 24,
                            filled: false,
                            shadowRadius: 50,
                            title: FlutterI18n.translate(context, 'send'),
                          ),
                          const SizedBox(
                            width: 32,
                          ),
                          MXCRectangleButton.icon(
                            key: const Key('receiveButton'),
                            iconFillColor: Colors.white,
                            color:
                                ColorsTheme.of(context).iconButtonInvertActive,
                            icon: MxcIcons.receive,
                            onTap: () => presenter.showReceiveSheet(),
                            titleStyle:
                                FontTheme.of(context).subtitle1.primary(),
                            iconSize: 24,
                            filled: false,
                            shadowRadius: 50,
                            title: FlutterI18n.translate(context, 'receive'),
                          ),
                          const SizedBox(
                            width: 32,
                          ),
                          MXCRectangleButton.icon(
                            key: const Key('historyButton'),
                            iconFillColor: Colors.white,
                            color:
                                ColorsTheme.of(context).iconButtonInvertActive,
                            icon: MxcIcons.history,
                            onTap: () => Navigator.of(context)
                                .push(route(const TransactionHistoryPage())),
                            titleStyle:
                                FontTheme.of(context).subtitle1.primary(),
                            iconSize: 24,
                            filled: false,
                            shadowRadius: 50,
                            title: FlutterI18n.translate(context, 'history'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
