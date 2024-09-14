import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:moonchain_wallet/main.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            appName,
            style: FontTheme.of(context).logo(),
          ),
        ],
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
          edgeType: UIConfig.splashScreensButtonsEdgeType,
          size: MXCWalletButtonSize.xxl,
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
