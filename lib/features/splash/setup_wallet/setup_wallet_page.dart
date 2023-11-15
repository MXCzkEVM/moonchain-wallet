import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
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
  EdgeInsets get childrenPadding => const EdgeInsets.all(0);

  @override
  bool get drawAnimated => true;

  @override
  Widget appLogo(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: SizedBox(
          width: 200,
          child: LottieBuilder.asset(
            'assets/lottie/axs_logo_animation.json',
            repeat: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) => Container();

  @override
  Widget? buildFooter(BuildContext context, WidgetRef ref) {
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
          textAlign: TextAlign.center,
          TextSpan(
            style: FontTheme.of(context).body1(),
            children: [
              TextSpan(
                text: FlutterI18n.translate(context, 'agree_terms_and_service'),
                style: FontTheme.of(context).caption2.textWhite(),
              ),
              const TextSpan(
                text: ' ',
              ),
              TextSpan(
                text: FlutterI18n.translate(context, 'terms_and_service'),
                style: FontTheme.of(context).caption2.textWhite().copyWith(
                      decoration: TextDecoration.underline,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap =
                      () => ref.read(presenter).launchAxsTermsConditions(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
