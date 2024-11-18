import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_custom_network_presenter.dart';

class AddCustomNetworkPage extends HookConsumerWidget {
  const AddCustomNetworkPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    String translate(String text) => FlutterI18n.translate(context, text);
    final presenter = ref.read(addCustomNetworkContainer.actions);
    final state = ref.watch(addCustomNetworkContainer.state);
    return MxcPage.layer(
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      layout: LayoutType.scrollable,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate('add_x')
              .replaceFirst('{0}', translate('custom_network')),
          actionText: translate('save'),
          onActionTap: () {
            if (!formKey.currentState!.validate()) return;
            presenter.onSave();
          },
          isActionTap: state.ableToSave,
        ),
        Form(
          key: formKey,
          child: Column(
            children: [
              MxcTextField(
                key: const ValueKey('networkNameTextField'),
                label: translate('network_name'),
                hint: '${translate('network_name')} (${translate('optional')})',
                controller: presenter.networkNameController,
                action: TextInputAction.next,
              ),
              MxcTextField(
                key: const ValueKey('rpcUrlTextField'),
                label: translate('rpc_url'),
                hint: translate('rpc_url'),
                controller: presenter.rpcUrlController,
                action: TextInputAction.next,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('rpc_url')));
                  if (res != null) return res;
                  return Validation.checkHttps(context, value!,
                      errorText: translate('invalid_url_format_notice'));
                },
                onChanged: (value) {
                  presenter.changeAbleToSave(
                      formKey.currentState!.validate() ? true : false);
                  presenter.onRpcUrlChange(value);
                },
                onFocused: (focused) =>
                    focused ? null : formKey.currentState!.validate(),
              ),
              MxcTextField(
                key: const ValueKey('chainIdTextField'),
                label: translate('chain_id'),
                hint: translate('chain_id'),
                controller: presenter.chainIdController,
                action: TextInputAction.done,
                validator: (value) {
                  if (value == null) return translate('chain_id_empty_notice');

                  final res = Validation.notEmpty(
                      context, value, translate('chain_id_empty_notice'));
                  if (res != null) return res;

                  final numericCheck = Validation.checkNumeric(context, value,
                      errorText: translate('invalid_number_notice'));
                  if (numericCheck != null) {
                    // not numeric
                    final hexDecimalCheck = Validation.checkHexDecimal(
                        context, value,
                        errorText: translate('invalid_number_notice'));
                    if (hexDecimalCheck != null) return hexDecimalCheck;
                    return presenter.compareChainId(context, value,
                        isNumeric: false);
                  } else {
                    return presenter.compareChainId(context, value);
                  }
                },
                onChanged: (value) {
                  presenter.changeAbleToSave(
                      formKey.currentState!.validate() ? true : false);
                },
                onFocused: (focused) =>
                    focused ? null : formKey.currentState!.validate(),
              ),
              MxcTextField(
                key: const ValueKey('symbolTextField'),
                label: translate('symbol'),
                hint: '${translate('currency')} ${translate('symbol')}',
                controller: presenter.symbolController,
                action: TextInputAction.next,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('symbol')));
                  if (res != null) return res;
                  return null;
                },
                onChanged: (value) {
                  presenter.changeAbleToSave(
                      formKey.currentState!.validate() ? true : false);
                },
              ),
              MxcTextField(
                key: const ValueKey('explorerTextField'),
                label: translate('block_explorer_url'),
                hint: translate('block_explorer_url'),
                controller: presenter.explorerController,
                action: TextInputAction.done,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty').replaceFirst(
                          '{0}', translate('block_explorer_url')));
                  if (res != null) return res;
                  return Validation.checkHttps(context, value);
                },
                onChanged: (value) {
                  presenter.changeAbleToSave(
                      formKey.currentState!.validate() ? true : false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
