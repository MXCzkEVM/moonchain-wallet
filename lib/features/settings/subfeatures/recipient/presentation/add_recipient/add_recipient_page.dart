import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_recipient_presenter.dart';
import 'add_recipient_state.dart';

class AddRecipientPage extends HookConsumerWidget {
  const AddRecipientPage({Key? key}) : super(key: key);

  @override
  ProviderBase<AddRecipientPresenter> get presenter =>
      addRecipientPageContainer.actions;

  @override
  ProviderBase<AddRecipientState> get state => addRecipientPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate('new_recipient'),
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
                key: const ValueKey('nameTextField'),
                label: '${translate('name')} *',
                hint: translate('recipient_name'),
                controller: ref.read(presenter).nameController,
                action: TextInputAction.next,
                validator: (value) => Validation.notEmpty(
                    context,
                    value,
                    translate('x_not_empty')
                        .replaceFirst('{0}', translate('name'))),
                onFocused: (focused) {
                  if (!focused) {
                    final res = formKey.currentState!.validate();
                    ref.read(presenter).onValidChange(res);
                  }
                },
              ),
              MxcTextField(
                key: const ValueKey('addressTextField'),
                label: '${translate('address_or_mns')} *',
                hint: translate('wallet_address_or_mns'),
                controller: ref.read(presenter).addressController,
                action: TextInputAction.done,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('address_or_mns')));
                  if (res != null) return res;

                  if (value!.startsWith('0x')) {
                    return Validation.checkEthereumAddress(context, value);
                  }

                  return null;
                },
                onFocused: (focused) {
                  if (!focused) {
                    final res = formKey.currentState!.validate();
                    ref.read(presenter).onValidChange(res);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
