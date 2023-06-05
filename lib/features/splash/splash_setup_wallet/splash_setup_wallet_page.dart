import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_setup_wallet_presenter.dart';
import 'splash_setup_wallet_state.dart';

class SplashSetupWalletPage extends SplashBasePage {
  const SplashSetupWalletPage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashSetupWalletPresenter> get presenter =>
      splashSetupWalletContainer.actions;

  @override
  ProviderBase<SplashSetupWalletState> get state =>
      splashSetupWalletContainer.state;

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    return [
      MxcFullRoundedButton(
        key: const ValueKey('createButton'),
        title: FlutterI18n.translate(context, 'create_wallet'),
        onTap: () => Navigator.of(context).push(
          route(
            const SplashStoragePage(),
          ),
        ),
      ),
      MxcFullRoundedButton(
        key: const ValueKey('importButton'),
        title: FlutterI18n.translate(context, 'import_wallet'),
        onTap: () => Navigator.of(context).push(
          route(
            const SplashImportStoragePage(),
          ),
        ),
      ),
    ];
  }
}
