import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'secured_storage_page_presentater.dart';

class SecuredStoragePage extends HookConsumerWidget with SplashScreenMixin {
  const SecuredStoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(securedStoragePageContainer.actions);
    final state = ref.watch(securedStoragePageContainer.state);

    return MxcContextHook(
      bridge: presenter.bridge,
      child: Material(
        child: appLinearBackground(
          child: Column(
            children: [
              Expanded(
                child: appLogo(context),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 76),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MxcFullRoundedButton(
                        key: const ValueKey('telegramButton'),
                        title: FlutterI18n.translate(
                            context, 'telegram_secured_storage'),
                        onTap: state.applist['telegram'] == true
                            ? () => presenter.shareToTelegram()
                            : null,
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      MxcFullRoundedButton(
                        key: const ValueKey('wechatButton'),
                        title: FlutterI18n.translate(
                            context, 'wechat_secured_storage'),
                        onTap: state.applist['wechat'] == true
                            ? () => presenter.shareToWechat()
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
