import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SplashStoragePage extends SplashBasePage {
  const SplashStoragePage({Key? key}) : super(key: key);

  @override
  ProviderBase<SplashStoragePagePresenter> get presenter =>
      splashStoragePageContainer.actions;

  @override
  ProviderBase<SplashStoragePageState> get state =>
      splashStoragePageContainer.state;

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    return [
      MxcFullRoundedButton(
        key: const ValueKey('telegramButton'),
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: ref.watch(state).applist['telegram'] == true
            ? () => ref.read(presenter).shareToTelegram()
            : null,
      ),
      MxcFullRoundedButton(
        key: const ValueKey('wechatButton'),
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap: ref.watch(state).applist['weixin'] == true ||
                ref.watch(state).applist['wechat'] == true
            ? () => ref.read(presenter).shareToWechat()
            : null,
      ),
    ];
  }
}
