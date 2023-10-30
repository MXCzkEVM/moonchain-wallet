import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/portfolio.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/add_token/add_token_page.dart';
import '../token/send_token/send_crypto/send_crypto_page.dart';
import './utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TokensBalanceList extends HookConsumerWidget {
  const TokensBalanceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioContainer.state);

    String translate(String text) => FlutterI18n.translate(context, text);

    return Column(
      children: [
        portfolioState.tokensList != null && portfolioState.tokensList!.isEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 100),
                alignment: Alignment.center,
                child: Text(
                  translate('no_tokens_added_yet'),
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
                                  onSelected: (token) =>
                                      Navigator.of(context).push(
                                    route.featureDialog(
                                      SendCryptoPage(
                                        token: token,
                                        isBalanceZero: portfolioState
                                                    .tokensList?[0].balance ==
                                                null
                                            ? false
                                            : portfolioState
                                                    .tokensList![0].balance! <=
                                                0.0,
                                      ),
                                    ),
                                  ),
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
              onTap: () => Navigator.of(context).push(
                route.featureDialog(
                  const AddTokenPage(),
                ),
              ),
              title: translate('add_x').replaceFirst(
                '{0}',
                translate('token').toLowerCase(),
              ),
              iconData: Icons.add,
              alignIconStart: true,
            ),
            const Spacer()
          ],
        ),
      ],
    );
  }
}
