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
    final presenter = ref.watch(securedStoragePageContainer.actions);

    return Material(
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
                      onTap: () {
                        openUrl('');
                      },
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    MxcFullRoundedButton(
                      key: const ValueKey('wechatButton'),
                      title: FlutterI18n.translate(
                          context, 'wechat_secured_storage'),
                      onTap: () async {
                        presenter.socialShare();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
