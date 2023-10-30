import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/tokens_balance_list/utils.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/send_token/send_crypto/send_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'choose_crypto_presenter.dart';
import 'choose_crypto_state.dart';

class ChooseCryptoPage extends HookConsumerWidget {
  const ChooseCryptoPage({
    Key? key,
    this.qrCode,
  }) : super(key: key);

  final String? qrCode;

  @override
  ProviderBase<ChooseCryptoPresenter> get presenter =>
      chooseCryptoPageContainer.actions;

  @override
  ProviderBase<ChooseCryptoState> get state => chooseCryptoPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      layout: LayoutType.column,
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
            child: Padding(
          padding: const EdgeInsets.only(top: 24, right: 24, left: 24),
          child: ListView(
            children: [
              Text(
                translate('send_x')
                    .replaceFirst('{0}', translate('token').toLowerCase()),
                style: FontTheme.of(context).h4(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translate('choose_x')
                        .replaceFirst('{0}', translate('token').toLowerCase()),
                    style: FontTheme.of(context).body1.secondary(),
                  ),
                  MxcTextField.search(
                    key: const ValueKey('chooseTokenTextField'),
                    width: 150,
                    backgroundColor: ColorsTheme.of(context).chipDefaultBg,
                    prefix: const Icon(Icons.search_rounded),
                    hint: translate('find_your_x')
                        .replaceFirst('{0}', translate('token').toLowerCase()),
                    controller: ref.read(presenter).searchController,
                    action: TextInputAction.done,
                    onChanged: (value) =>
                        ref.read(presenter).fliterTokenByName(value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (ref.watch(state).filterTokens != null)
                GreyContainer(
                    child: Column(
                  children: [
                    ...TokensBalanceListUtils.generateTokensBalanceList(
                      ref.watch(state).filterTokens!,
                      onSelected: (token) => Navigator.of(context).push(
                        route.featureDialog(
                          SendCryptoPage(
                            token: token,
                            qrCode: qrCode,
                            isBalanceZero:
                                ref.watch(state).tokens?[0].balance == null
                                    ? false
                                    : ref.watch(state).tokens![0].balance! <=
                                        0.0,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
            ],
          ),
        ))
      ],
    );
  }
}
