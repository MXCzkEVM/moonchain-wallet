import 'dart:ui';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/presentation/tokens_balance_list/tokens_balance_list.dart';
import 'package:datadashwallet/features/token/send_token/choose_crypto/choose_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'portfolio_page_presenter.dart';
import 'portfolio_page_state.dart';
import 'presentation/nfts/nfts.dart';

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
            icon: const Icon(MXCIcons.dapps),
            iconSize: 24,
            onPressed: () =>
                Navigator.of(context).replaceAll(route(const DAppsPage())),
            color: ColorsTheme.of(context).primaryButton,
          ),
        ),
        floatingActionButton: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight(
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                          icon: MXCIcons.send,
                          onTap: () => Navigator.of(context)
                              .push(route(const ChooseCryptoPage())),
                          iconSize: 24,
                          filled: false,
                          color: ColorsTheme.of(context).primaryBackground,
                          iconFillColor: ColorsTheme.of(context).white,
                          shadowRadius: 50,
                          title: FlutterI18n.translate(context, 'send'),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        MxcCircleButton.icon(
                          key: const Key('receiveButton'),
                          icon: MXCIcons.receive,
                          onTap: () {},
                          iconSize: 24,
                          filled: false,
                          color: ColorsTheme.of(context).primaryBackground,
                          iconFillColor: ColorsTheme.of(context).white,
                          shadowRadius: 50,
                          title: FlutterI18n.translate(context, 'receive'),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        MxcCircleButton.icon(
                          key: const Key('historyButton'),
                          icon: MXCIcons.history,
                          onTap: () {},
                          iconSize: 24,
                          filled: false,
                          color: ColorsTheme.of(context).primaryBackground,
                          iconFillColor: ColorsTheme.of(context).white,
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onTap: () => presenter.changeTokensOrNFTsTab(),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onTap: () => presenter.changeTokensOrNFTsTab(),
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
                const NFTsContent(),
              ]
            ],
          ))
        ]);
  }
}
