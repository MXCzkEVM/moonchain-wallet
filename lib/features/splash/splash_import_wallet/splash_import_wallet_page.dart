import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_import_wallet_page_presenter.dart';
import 'splash_import_wallet_page_state.dart';

class SplashImportWalletPage extends HookConsumerWidget {
  const SplashImportWalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashImportWalletPageContainer.actions);

    return MxcPage(
      layout: LayoutType.column,
      useAppLinearBackground: true,
      presenter: presenter,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 80,
              ),
              Text(
                FlutterI18n.translate(context, 'import_your_wallet'),
                style: FontTheme.of(context).h5.white(),
              ),
              const SizedBox(
                height: 29,
              ),
              Text(
                FlutterI18n.translate(context, 'word_seed_phrase'),
                style: FontTheme.of(context).body1.secondary(),
              ),
              const SizedBox(
                height: 50,
              ),
              MxcTextField.multiline(
                key: const ValueKey('mnemonicInput'),
                controller: TextEditingController(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MxcFullRoundedButton(
                  key: const ValueKey('confrimButton'),
                  title:
                      FlutterI18n.translate(context, 'confrim').toUpperCase(),
                  onTap: () => Navigator.of(context).pushReplacement(
                    route(
                      const PasscodeSetPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
