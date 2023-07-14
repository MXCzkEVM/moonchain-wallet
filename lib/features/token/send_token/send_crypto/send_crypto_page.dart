import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_crypto_presenter.dart';
import 'send_crypto_state.dart';

class SendCryptoPage extends HookConsumerWidget {
  const SendCryptoPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  final Token token;

  @override
  ProviderBase<SendCryptoPresenter> get presenter =>
      addTokenPageContainer.actions;

  @override
  ProviderBase<SendCryptoState> get state => addTokenPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.text(
            titleText:
                translate('send_x').replaceFirst('{0}', token.name ?? '')),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('network'),
                style: FontTheme.of(context).caption1.primary(),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                        color: ref.watch(state).online
                            ? ColorsTheme.of(context).systemStatusActive
                            : ColorsTheme.of(context).mainRed,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    translate('MXC zkEVM'),
                    style: FontTheme.of(context).body1.secondary(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              MxcTextField(
                key: const ValueKey('amountTextField'),
                label: '${translate('amount_to_send')} *',
                controller: ref.read(presenter).amountController,
                action: TextInputAction.next,
                // validator: (v) => Validation.checkUrl(context, v),
                hint: 'e.g 100',
              ),
              Row(
                  children: ['25%', '50%', '75%']
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: MxcChipButton(
                              key: Key('button$item'),
                              buttonState: ChipButtonStates.inactiveState,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              onTap: () {},
                              width: 80,
                              title: item,
                            ),
                          ))
                      .toList()),
              const SizedBox(height: 24),
              MxcTextField(
                key: const ValueKey('recipientTextField'),
                label: '${translate('recipient')} *',
                controller: ref.read(presenter).recipientController,
                action: TextInputAction.done,
                // validator: (v) => Validation.checkUrl(context, v),
                hint: translate('wallet_address_or_mns'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
