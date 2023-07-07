import 'package:datadashwallet/features/portfolio/presentation/tokens_balance_list/tokens_balance_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'portfolio_page_presenter.dart';
import 'portfolio_page_state.dart';

class PortfolioPage extends HookConsumerWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);

    return MxcPage(
        useAppBar: true,
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).secondaryBackground,
        layout: LayoutType.column,
        useContentPadding: false,
        childrenPadding: const EdgeInsets.only(top: 25, right: 24, left: 24),
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
                color: ColorsTheme.of(context).white.withOpacity(0.2),
                width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: ColorsTheme.of(context).box,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MxcCircleButton.icon(
                key: const Key('sendButton'),
                icon: MXCIcons.send,
                onTap: () {},
                iconSize: 24,
                filled: false,
                color: ColorsTheme.of(context).primaryBackground,
                iconFillColor: ColorsTheme.of(context).white,
                shadowRadius: 50,
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
              ),
              const SizedBox(
                width: 32,
              ),
              MxcCircleButton.icon(
                key: const Key('historyButton'),
                icon: Icons.history,
                onTap: () {},
                iconSize: 24,
                filled: false,
                color: ColorsTheme.of(context).primaryBackground,
                iconFillColor: ColorsTheme.of(context).white,
                shadowRadius: 50,
              ),
            ],
          ),
        ),
        children: [
          Expanded(
              child: ListView(
            children: [
              Text(FlutterI18n.translate(context, 'portfolio'),
                  style: FontTheme.of(context).h4().copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: ColorsTheme.of(context).primaryText)),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    titleStyle: FontTheme.of(context).h7().copyWith(
                          fontSize: 14,
                        ),
                    onTap: () {},
                    title: FlutterI18n.translate(context, 'tokens'),
                    buttonDecoration: BoxDecoration(
                        color: ColorsTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: ColorsTheme.of(context).white,
                        )),
                    alignIconStart: true,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MxcChipButton(
                    key: const Key('nftsTabButton'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    titleStyle: FontTheme.of(context).h7().copyWith(
                        fontSize: 14,
                        color: ColorsTheme.of(context).secondaryBackground),
                    onTap: () {},
                    title: FlutterI18n.translate(context, 'nfts'),
                    buttonDecoration: BoxDecoration(
                        color: ColorsTheme.of(context).white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: ColorsTheme.of(context).secondaryBackground,
                        )),
                    alignIconStart: true,
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const TokensBalanceList(),
            ],
          ))
        ]);
  }
}
