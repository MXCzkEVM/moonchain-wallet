import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'setup_wallet_presenter.dart';
import 'setup_wallet_state.dart';

class SplashSetupWalletPage extends SplashBasePage {
  const SplashSetupWalletPage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashSetupWalletPresenter> get presenter =>
      splashSetupWalletContainer.actions;

  @override
  ProviderBase<SplashSetupWalletState> get state =>
      splashSetupWalletContainer.state;

  @override
  bool get drawAnimated => true;

  @override
  Widget? buildFooter(BuildContext context) {
    return Column(
      children: [
        MxcButton.primaryWhite(
          key: const ValueKey('createButton'),
          title: FlutterI18n.translate(context, 'create_wallet'),
          onTap: () => Navigator.of(context).push(
            route(
              const SplashStoragePage(),
            ),
          ),
        ),
        MxcButton.plainWhite(
          key: const ValueKey('importButton'),
          title: FlutterI18n.translate(context, 'import_wallet'),
          onTap: () => Navigator.of(context).push(
            route(
              const SplashImportStoragePage(),
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            style: FontTheme.of(context).body1(),
            children: [
              TextSpan(
                text: FlutterI18n.translate(context, 'agree_terms_and_service'),
                style: FontTheme.of(context).caption1.white(),
              ),
              const TextSpan(
                text: ' ',
              ),
              TextSpan(
                text: FlutterI18n.translate(context, 'terms_and_service'),
                style: FontTheme.of(context).caption1.white().copyWith(
                      decoration: TextDecoration.underline,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap =
                      () => openUrl('https://www.mxc.org/terms-and-conditions'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
