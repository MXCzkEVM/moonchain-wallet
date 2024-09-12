import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/qr_code/qr_scanner/qr_scanner_page.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/qr_code/show_qa_code/qr_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../../../../core/src/routing/route.dart';
import '../../entities/recipient.dart';
import 'edit_recipient_presenter.dart';
import 'edit_recipient_state.dart';

class EditRecipientPage extends HookConsumerWidget {
  const EditRecipientPage({
    Key? key,
    this.editFlow = false,
    this.recipient,
  }) : super(key: key);

  final bool editFlow;
  final Recipient? recipient;

  @override
  ProviderBase<EditRecipientPresenter> get presenter =>
      editRecipientContainer.actions(recipient);

  @override
  ProviderBase<EditRecipientState> get state =>
      editRecipientContainer.state(recipient);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return (editFlow ? MxcPage.new : MxcPage.layer)(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate(editFlow ? 'edit_recipient' : 'new_recipient'),
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
                  if (!focused) formKey.currentState!.validate();
                },
              ),
              MxcTextField(
                  key: const ValueKey('addressTextField'),
                  label: '${translate('address_or_mns')} *',
                  hint: translate('wallet_address_or_mns'),
                  controller: ref.read(presenter).addressController,
                  action: TextInputAction.done,
                  errorText: ref.watch(state).errorText,
                  validator: (value) {
                    final res = Validation.notEmpty(
                        context,
                        value,
                        translate('x_not_empty')
                            .replaceFirst('{0}', translate('address_or_mns')));
                    if (res != null) return res;

                    if (value!.startsWith('0x')) {
                      return Validation.checkEthereumAddress(context, value);
                    } else {
                      return Validation.checkMnsValidation(context, value);
                    }
                  },
                  suffixButton: MxcTextFieldButton.icon(
                    icon: MxcIcons.qr_code,
                    onTap: () async {
                      String qrCode = await Navigator.of(context)
                          .push(route(const QrScannerPage(
                        returnQrCode: true,
                      )));
                      ref.read(presenter).addressController.text = qrCode;
                      formKey.currentState!.validate();
                    },
                  ),
                  onFocused: (focused) {
                    ref.read(presenter).resetValidation();
                    if (!focused) {
                      if (!focused) formKey.currentState!.validate();
                    }
                  }),
              if (editFlow) ...[
                const SizedBox(height: Sizes.spaceXLarge),
                MxcButton.plain(
                  key: const ValueKey('deleteButton'),
                  title: FlutterI18n.translate(context, 'delete_recipient'),
                  titleColor: ColorsTheme.of(context).textCritical,
                  onTap: () async {
                    final result = await showAlertDialog(
                      context: context,
                      title: 'delete_recipient',
                      ok: 'delete',
                    );
                    if (result != null && result) {
                      ref.read(presenter).deleteRecipient(recipient!);
                    }
                  },
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
