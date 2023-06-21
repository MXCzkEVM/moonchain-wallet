import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SplashStoragePage extends SplashBasePage {
  const SplashStoragePage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashStoragePresenter> get presenter =>
      splashStorageContainer.actions;

  @override
  ProviderBase<SplashBaseState> get state => splashStorageContainer.state;

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) {
    return MxcAppBar.splash(
        text: FlutterI18n.translate(context, 'create_wallet'));
  }

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    return [
      MxcButton.secondary(
        key: const ValueKey('telegramButton'),
        icon: 'assets/svg/splash/ic_telegram.svg',
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: ref.watch(state).applist['telegram'] == true
            ? () => ref.read(presenter).shareToTelegram()
            : null,
      ),
      MxcButton.secondary(
        key: const ValueKey('wechatButton'),
        icon: 'assets/svg/splash/ic_wechat.svg',
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap: ref.watch(state).applist['weixin'] == true ||
                ref.watch(state).applist['wechat'] == true
            ? () => ref.read(presenter).shareToWechat()
            : null,
      ),
      MxcButton.secondary(
        key: const ValueKey('emailButton'),
        icon: 'assets/svg/splash/ic_mail.svg',
        title: FlutterI18n.translate(context, 'email_secured_storage'),
        onTap: () => ref.read(presenter).sendEmail(),
      ),
    ];
  }
}
