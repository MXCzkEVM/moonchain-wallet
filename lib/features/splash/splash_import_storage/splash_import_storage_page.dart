import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_import_storage_presenter.dart';

class SplashImportStoragePage extends SplashBasePage {
  const SplashImportStoragePage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashImportStoragePresenter> get presenter =>
      splashImportStorageContainer.actions;

  @override
  ProviderBase<SplashBaseState> get state =>
      splashImportStorageContainer.state;

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    return [
      MxcFullRoundedButton(
        key: const ValueKey('telegramButton'),
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: ref.watch(state).applist['telegram'] == true
            ? () => ref.read(presenter).openTelegram()
            : null,
      ),
      MxcFullRoundedButton(
        key: const ValueKey('wechatButton'),
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap: ref.watch(state).applist['weixin'] == true ||
                ref.watch(state).applist['wechat'] == true
            ? () => ref.read(presenter).openWechat()
            : null,
      ),
      MxcFullRoundedButton(
        key: const ValueKey('mnemonicButton'),
        title: FlutterI18n.translate(context, 'mnemonic_phrase'),
        onTap: () => Navigator.of(context).pushReplacement(
          route(
            const SplashImportWalletPage(),
          ),
        ),
      ),
      // MxcFullRoundedButton(
      //   key: const ValueKey('emailButton'),
      //   title: FlutterI18n.translate(context, 'email_secured_storage'),
      //   onTap: () => ref.read(presenter).openEmail(),
      // ),
    ];
  }
}
