import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/widgets/nft_item.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/address_book/address_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_nft_presenter.dart';
import 'send_nft_state.dart';

class SendNftPage extends HookConsumerWidget {
  const SendNftPage({
    Key? key,
    required this.nft,
  }) : super(key: key);

  final Nft nft;

  @override
  ProviderBase<SendNftPresenter> get presenter =>
      sendNftPageContainer.actions(nft);

  @override
  ProviderBase<SendNftState> get state => sendNftPageContainer.state(nft);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: ref.watch(presenter).recipientController,
            builder: (ctx, recipientValue, _) {
              return MxcButton.primary(
                key: const ValueKey('nextButton'),
                title: FlutterI18n.translate(context, 'next'),
                onTap: null,
                // recipientValue.text.isNotEmpty
                //     ? () {
                //         FocusManager.instance.primaryFocus?.unfocus();

                //         if (!formKey.currentState!.validate()) return;

                //         ref.read(presenter).transactionProcess();
                //       }
                //     : null,
              );
            }),
      ),
      children: [
        MxcAppBarEvenly.text(
            titleText: translate('send_x').replaceFirst('{0}', 'NFT')),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: NFTItem(
                  imageUrl: nft.image,
                ),
              ),
              const SizedBox(height: 24),
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
                    'MXC zkEVM',
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
                    // formKey.currentState!.validate();
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
