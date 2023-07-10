import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_token_presenter.dart';
import 'add_token_state.dart';

class AddTokenPage extends HookConsumerWidget {
  const AddTokenPage({Key? key}) : super(key: key);

  @override
  ProviderBase<AddTokenPresenter> get presenter =>
      addTokenPageContainer.actions;

  @override
  ProviderBase<AddTokenPageState> get state => addTokenPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<TextEditingValue>(
            valueListenable: ref.watch(presenter).addressController,
            builder: (ctx, addressValue, _) {
              return MxcAppBarEvenly.text(
                titleText: 'add_token',
                actionText: 'save',
                onActionTap: () => ref.read(presenter).onSave(),
                isActionTap: addressValue.text.isNotEmpty,
              );
            }),
        Form(
          key: formKey,
          child: Column(
            children: [
              MxcTextField(
                key: const ValueKey('addressTextField'),
                label: '${translate('token_contract_addresss')} *',
                hint: translate('enter_x').replaceFirst(
                    '{0}', translate('token_contract_addresss').toLowerCase()),
                controller: ref.read(presenter).addressController,
                action: TextInputAction.done,
                validator: (value) => Validation.notEmpty(
                    context, value, 'token_contract_addresss_not_empty'),
                onChanged: (value) => ref.read(presenter).onChanged(value),
              ),
              MxcTextField(
                key: const ValueKey('symbolTextField'),
                label: translate('token_symbol'),
                hint: translate('enter_x').replaceFirst(
                    '{0}', translate('token_symbol').toLowerCase()),
                controller: ref.read(presenter).symbolController,
                action: TextInputAction.next,
              ),
              MxcTextField(
                key: const ValueKey('decimalTextField'),
                label: translate('token_decimal'),
                hint: translate('enter_x').replaceFirst(
                    '{0}', translate('token_decimal').toLowerCase()),
                controller: ref.read(presenter).decimalController,
                action: TextInputAction.done,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
