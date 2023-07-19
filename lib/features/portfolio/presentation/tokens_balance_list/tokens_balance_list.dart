import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page_presenter.dart';
import 'package:datadashwallet/features/token/add_token/add_token_page.dart';
import './utils.dart';
import 'package:datadashwallet/features/home/home/home_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TokensBalanceList extends HookConsumerWidget {
  const TokensBalanceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioContainer.state);

    return Column(
      children: [
        portfolioState.tokensList != null && portfolioState.tokensList!.isEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 100),
                alignment: Alignment.center,
                child: Text(
                  FlutterI18n.translate(context, 'no_tokens_added_yet'),
                  style: FontTheme.of(context).h6().copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                      ),
                ),
              )
            : Column(
                children: [
                  GreyContainer(
                      child: portfolioState.tokensList == null
                          ? const SizedBox(
                              height: 50,
                              child: Center(child: CircularProgressIndicator()))
                          : Column(
                              children: [
                                ...TokensBalanceListUtils
                                    .generateTokensBalanceList(
                                  portfolioState.tokensList!,
                                )
                              ],
                            )),
                ],
              ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const Spacer(),
            MxcChipButton(
              key: const Key('addTokenButton'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onTap: () => Navigator.of(context).push(
                route.featureDialog(
                  const AddTokenPage(),
                ),
              ),
              title: FlutterI18n.translate(context, 'add_token'),
              iconData: Icons.add,
              alignIconStart: true,
            ),
            const Spacer()
          ],
        ),
        const SizedBox(
          height: 120,
        ),
      ],
    );
  }
}
