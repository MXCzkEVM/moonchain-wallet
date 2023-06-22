import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'import_storage_presenter.dart';

class SplashImportStoragePage extends SplashBasePage {
  const SplashImportStoragePage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashImportStoragePresenter> get presenter =>
      splashImportStorageContainer.actions;

  @override
  ProviderBase<SplashBaseState> get state => splashImportStorageContainer.state;

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) {
    return MxcAppBar.splashBack(
        text: FlutterI18n.translate(context, 'import_wallet'));
  }

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    return [
      MxcButton.secondary(
        key: const ValueKey('telegramButton'),
        icon: 'assets/svg/splash/ic_telegram.svg',
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: ref.watch(state).applist['telegram'] == true
            ? () => ref.read(presenter).openTelegram()
            : null,
      ),
      MxcButton.secondary(
        key: const ValueKey('wechatButton'),
        icon: 'assets/svg/splash/ic_wechat.svg',
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap: ref.watch(state).applist['weixin'] == true ||
                ref.watch(state).applist['wechat'] == true
            ? () => ref.read(presenter).openWechat()
            : null,
      ),
      MxcButton.secondary(
        key: const ValueKey('emailButton'),
        icon: 'assets/svg/splash/ic_email.svg',
        title: FlutterI18n.translate(context, 'email_secured_storage'),
        onTap: () => ref.read(presenter).openEmail(),
      ),
      MxcButton.secondary(
        key: const ValueKey('mnemonicButton'),
        icon: 'assets/svg/splash/ic_cloud.svg',
        title: FlutterI18n.translate(context, 'secret_recovery_phrase'),
        onTap: () => Navigator.of(context).pushReplacement(
          route(
            const SplashImportWalletPage(),
          ),
        ),
      ),
    ];
  }
}
