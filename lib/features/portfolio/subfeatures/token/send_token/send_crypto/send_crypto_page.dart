import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/address_book/address_book.dart';
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
    this.qrCode,
  }) : super(key: key);

  final Token token;
  final String? qrCode;

  @override
  ProviderBase<SendCryptoPresenter> get presenter =>
      sendTokenPageContainer.actions(MultiParameters(
        token: token,
        qrCode: qrCode,
      ));

  @override
  ProviderBase<SendCryptoState> get state =>
      sendTokenPageContainer.state(MultiParameters(
        token: token,
        qrCode: qrCode,
      ));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: MxcButton.primary(
          key: const ValueKey('nextButton'),
          title: FlutterI18n.translate(context, 'next'),
          onTap: ref.watch(state).valid
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (!formKey.currentState!.validate()) return;

                  ref.read(presenter).transactionProcess();
                }
              : null,
        ),
      ),
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
                    ref.watch(state).network?.label ?? '--',
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
                keyboardType: TextInputType.number,
                action: TextInputAction.next,
                validator: (v) => Validation.notEmpty(
                    context,
                    v,
                    translate('x_not_empty')
                        .replaceFirst('{0}', translate('amount'))),
                hint: 'e.g 100',
                suffixText: token.symbol,
                suffixButton: MxcTextFieldButton.text(
                  text: translate('max'),
                  onTap: () {
                    ref.read(presenter).changeDiscount(100);
                    formKey.currentState!.validate();
                  },
                ),
                onFocused: (focused) =>
                    focused ? null : formKey.currentState!.validate(),
              ),
              Row(
                  children: [25, 50, 75]
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: MxcChipButton(
                              key: ValueKey('button$item'),
                              onTap: () {
                                ref.read(presenter).changeDiscount(item);
                                formKey.currentState!.validate();
                              },
                              width: 80,
                              title: '$item%',
                              buttonState: ref.watch(state).discount == item
                                  ? ChipButtonStates.activeState
                                  : ChipButtonStates.inactiveState,
                            ),
                          ))
                      .toList()),
              const SizedBox(height: 24),
              MxcTextField(
                key: const ValueKey('recipientTextField'),
                label: '${translate('recipient')} *',
                controller: ref.read(presenter).recipientController,
                action: TextInputAction.done,
                validator: (v) => Validation.notEmpty(
                    context,
                    v,
                    translate('x_not_empty')
                        .replaceFirst('{0}', translate('recipient'))),
                hint: translate('wallet_address_or_mns'),
                suffixButton: MxcTextFieldButton.svg(
                  svg: 'assets/svg/ic_contact.svg',
                  onTap: () async {
                    Recipient res = await Navigator.of(context)
                        .push(route(const SelectRecipientPage()));

                    ref.read(presenter).recipientController.text =
                        res.address ?? res.mns ?? '';
                    formKey.currentState!.validate();
                  },
                ),
                onFocused: (focused) =>
                    focused ? null : formKey.currentState!.validate(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
