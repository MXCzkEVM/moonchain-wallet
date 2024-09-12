import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'import_wallet_presenter.dart';

class SplashImportWalletPage extends HookConsumerWidget {
  const SplashImportWalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashImportWalletContainer.actions);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return MxcPage(
      useSplashBackground: true,
      presenter: presenter,
      appBar: MxcAppBar.splashBack(
        text: FlutterI18n.translate(context, 'secret_recovery_phrase'),
      ),
      footer: ValueListenableBuilder<TextEditingValue>(
          valueListenable: presenter.mnemonicController,
          builder: (ctx, mnemonicValue, _) {
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
              child: MxcButton.primaryWhite(
                key: const Key('importWalletButton'),
                title: FlutterI18n.translate(context, 'import_wallet'),
                onTap: mnemonicValue.text.isNotEmpty
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();

                        if (!formKey.currentState!.validate()) return;
                        presenter.confirm();
                      }
                    : null,
                edgeType: MXCWalletButtonEdgeType.hard,
              ),
            );
          }),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(context, 'import_your_wallet'),
              style: FontTheme.of(context).h4.white(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                FlutterI18n.translate(context, 'word_seed_phrase'),
                style: FontTheme.of(context).body1.white(),
              ),
            ),
            Form(
              key: formKey,
              child: MxcTextField.multiline(
                key: const ValueKey('mnemonicTextField'),
                textColor: ColorsTheme.of(context).textWhite,
                controller: presenter.mnemonicController,
                hint: FlutterI18n.translate(
                    context, 'enter_secret_recovery_phrase'),
                action: TextInputAction.done,
                validator: (v) => presenter.validate(v),
                autoFocus: true,
                borderUnFocusColor: ColorsTheme.of(context).borderPrimary100,
                borderFocusColor: ColorsTheme.of(context).borderPrimary200,
                suffixButton: MxcTextFieldButton.icon(
                    icon: MxcIcons.clipboard,
                    onTap: () {
                      presenter.pastFromClipBoard();
                    }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
