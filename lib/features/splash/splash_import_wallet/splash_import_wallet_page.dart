import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_import_wallet_presenter.dart';
import 'splash_import_wallet_state.dart';

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
      footer: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcFullRoundedButton(
              key: const Key('confrimPhrasesButton'),
              title: FlutterI18n.translate(context, 'confrim').toUpperCase(),
              onTap: () => presenter.confirm(),
            ),
          ],
        ),
      ),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Text(
              FlutterI18n.translate(context, 'import_your_wallet'),
              style: FontTheme.of(context).h5.white(),
            ),
            const SizedBox(height: 29),
            Text(
              FlutterI18n.translate(context, 'word_seed_phrase'),
              style: FontTheme.of(context).body1.secondary(),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                controller: state.mnemonicController,
                maxLines: 7,
                style: FontTheme.of(context).body1.white(),
                decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, 'mnemonic_passphrase'),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
