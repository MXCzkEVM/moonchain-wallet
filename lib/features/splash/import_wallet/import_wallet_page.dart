import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'import_wallet_presenter.dart';
import 'import_wallet_state.dart';

class SplashImportWalletPage extends HookConsumerWidget {
  const SplashImportWalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashImportWalletContainer.actions);
    final state = ref.watch(splashImportWalletContainer.state);

    return MxcPage(
      layout: LayoutType.scrollable,
      useSplashBackground: true,
      presenter: presenter,
      appBar: MxcAppBar.splashBack(
        text: FlutterI18n.translate(context, 'secret_recovery_phrase'),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: MxcButton.primary(
          key: const Key('importWalletButton'),
          title: FlutterI18n.translate(context, 'import_wallet').toUpperCase(),
          onTap: state.errorText == null &&
                  state.mnemonicController.text.isNotEmpty
              ? () => presenter.confirm()
              : null,
        ),
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(context, 'import_your_wallet'),
              style: FontTheme.of(context).h4.white(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              child: Text(
                FlutterI18n.translate(context, 'word_seed_phrase'),
                style: FontTheme.of(context).body1.white(),
              ),
            ),
            MxcTextfield(
              maxLines: 7,
              controller: state.mnemonicController,
              onChanged: (v) => presenter.validate(),
              errorText: state.errorText,
            ),
          ],
        ),
      ],
    );
  }
}
