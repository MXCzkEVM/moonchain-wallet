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
    required this.isBalanceZero,
  }) : super(key: key);

  final Token token;
  final String? qrCode;
  final bool isBalanceZero;

  @override
  ProviderBase<SendCryptoPresenter> get presenter =>
      sendTokenPageContainer.actions(SendCryptoArguments(
        token: token,
        qrCode: qrCode,
      ));

  @override
  ProviderBase<SendCryptoState> get state =>
      sendTokenPageContainer.state(SendCryptoArguments(
        token: token,
        qrCode: qrCode,
      ));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                  if (!ref.watch(state).formKey.currentState!.validate()) {
                    ref.watch(presenter).validateAndUpdate();
                    return;
                  }

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
          key: ref.watch(state).formKey,
          child: Column(
            children: [
              MxcTextField(
                key: const ValueKey('amountTextField'),
                label: '${translate('amount_to_send')} *',
                controller: ref.read(presenter).amountController,
                keyboardType: TextInputType.number,
                action: TextInputAction.next,
                validator: (v) {
                  v = ref.read(presenter).amountController.text;
                  final res = Validation.notEmpty(
                      context,
                      v,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('amount')));
                  if (res != null) {
                    return res;
                  }
                  try {
                    final doubleValue = double.parse(v);
                    String stringValue = doubleValue.toString();

                    int decimalPlaces = stringValue.split('.')[1].length;

                    if (doubleValue.isNegative ||
                        decimalPlaces > Config.decimalWriteFixed) {
                      return translate('invalid_format');
                    }
                    return ref.read(presenter).checkAmountCeiling();
                  } catch (e) {
                    return translate('invalid_format');
                  }
                },
                hint: 'e.g 100',
                suffixText: token.symbol,
                suffixButton: MxcTextFieldButton.text(
                  text: translate('max'),
                  onTap: () {
                    ref.read(presenter).changeDiscount(100);
                    ref.watch(state).formKey.currentState!.validate();
                  },
                ),
              ),
              Row(
                  children: [25, 50, 75]
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: MxcChipButton(
                              key: ValueKey('button$item'),
                              onTap: () {
                                ref.read(presenter).changeDiscount(item);
                                ref
                                    .watch(state)
                                    .formKey
                                    .currentState!
                                    .validate();
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
                controller: ref.watch(presenter).recipientController,
                action: TextInputAction.done,
                validator: (v) {
                  v = ref.read(presenter).recipientController.text;
                  final res = Validation.notEmpty(
                      context,
                      v,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('recipient')));
                  if (res != null) {
                    return res;
                  }
                  if (v.startsWith('0x')) {
                    return Validation.checkEthereumAddress(context, v);
                  } else {
                    return Validation.checkMnsValidation(context, v);
                  }
                },
                hint: translate('wallet_address_or_mns'),
                suffixButton: MxcTextFieldButton.svg(
                  svg: 'assets/svg/ic_contact.svg',
                  onTap: () async {
                    Recipient res = await Navigator.of(context)
                        .push(route(const SelectRecipientPage()));

                    ref.read(presenter).recipientController.text =
                        res.address ?? res.mns ?? '';
                    ref.watch(state).formKey.currentState!.validate();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
