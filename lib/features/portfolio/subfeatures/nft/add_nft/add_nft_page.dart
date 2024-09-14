import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_nft_presenter.dart';
import 'add_nft_state.dart';

class AddNftPage extends HookConsumerWidget {
  const AddNftPage({Key? key}) : super(key: key);

  @override
  ProviderBase<AddNftPresenter> get presenter => addNftPageContainer.actions;

  @override
  ProviderBase<AddNftState> get state => addNftPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate('add_nft'),
          actionText: translate('save'),
          onActionTap: () {
            if (!formKey.currentState!.validate()) return;
            ref.read(presenter).onSave();
          },
          isActionTap: ref.watch(state).valid,
        ),
        Form(
          key: formKey,
          child: Column(
            children: [
              MxcTextField(
                key: const ValueKey('addressTextField'),
                label: '${translate('address')} *',
                hint: translate('enter_x')
                    .replaceFirst('{0}', translate('address').toLowerCase()),
                controller: ref.read(presenter).addressController,
                action: TextInputAction.next,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('wallet_address')));
                  if (res != null) return res;

                  return Validation.checkEthereumAddress(context, value!);
                },
                onFocused: (focused) =>
                    focused ? null : formKey.currentState!.validate(),
              ),
              MxcTextField(
                key: const ValueKey('idTextField'),
                label: '${translate('id')} *',
                hint: translate('enter_x').replaceFirst(
                    '{0}', translate('collection_id').toLowerCase()),
                controller: ref.read(presenter).tokeIdController,
                action: TextInputAction.done,
                validator: (value) => Validation.notEmpty(
                    context,
                    value,
                    translate('x_not_empty')
                        .replaceFirst('{0}', translate('id'))),
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
