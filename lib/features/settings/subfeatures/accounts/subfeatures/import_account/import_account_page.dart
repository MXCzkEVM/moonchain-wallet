import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'import_account_presenter.dart';

class ImportAccountPage extends HookConsumerWidget {
  const ImportAccountPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    String translate(String text) => FlutterI18n.translate(context, text);
    final presenter = ref.read(importAccountContainer.actions);
    final state = ref.watch(importAccountContainer.state);
    return MxcPage.layer(
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      layout: LayoutType.scrollable,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate('import_account'),
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
                key: const ValueKey('privateKeyTextField'),
                label: translate('private_key'),
                hint: translate('private_key'),
                controller: presenter.privateKeyController,
                action: TextInputAction.next,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('private_key')));
                  if (res != null) return res;

                  final isPrivateKey =
                      Validation.checkEthereumPrivateKey(context, value ?? '');
                  if (isPrivateKey != null) return isPrivateKey;

                  return presenter.checkDuplicate(value ?? '');
                },
                onChanged: (value) {
                  presenter.changeAbleToSave(
                      formKey.currentState!.validate() ? true : false);
                },
              ),
              // MxcTextField(
              //   key: const ValueKey('accountNameTextField'),
              //   label: translate('account_name'),
              //   hint: translate('account_name'),
              //   controller: presenter.rpcUrlController,
              //   action: TextInputAction.next,
              //   validator: (value) {
              //     final res = Validation.notEmpty(
              //         context,
              //         value,
              //         translate('x_not_empty')
              //             .replaceFirst('{0}', translate('account_name')));
              //     if (res != null) return res;
              //     return Validation.checkHttps(context, value!,
              //         errorText: translate('invalid_url_format_notice'));
              //   },
              //   onChanged: (value) {
              //     presenter.changeAbleToSave(
              //         formKey.currentState!.validate() ? true : false);
              //     presenter.onRpcUrlChange(value);
              //   },
              //   onFocused: (focused) =>
              //       focused ? null : formKey.currentState!.validate(),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
