import 'dart:io';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SplashStoragePage extends SplashBasePage {
  const SplashStoragePage({
    Key? key,
    this.settingsFlow = false,
    this.pageTitle,
  }) : super(key: key);

  final bool settingsFlow;
  final String? pageTitle;

  @override
  ProviderBase<SplashStoragePresenter> get presenter =>
      splashStorageContainer.actions;

  @override
  ProviderBase<SplashBaseState> get state => splashStorageContainer.state;

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) {
    return MxcAppBar.splashBack(
        text: FlutterI18n.translate(context, pageTitle ?? 'create_wallet'));
  }

  MXCWalletButtonEdgeType getPageButtonsEdge() => MXCWalletButtonEdgeType.hard;

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    final isEmailAvailable = ref.watch(state).isEmailAppAvailable == true;
    final isTelegramAvailable = ref.watch(state).applist['telegram'] == true ||
        ref.watch(state).applist['telegram_web'] == true;
    final isWeChatAvailable = ref.watch(state).applist['weixin'] == true ||
        ref.watch(state).applist['wechat'] == true;
    final isNoneAvailable =
        !(isEmailAvailable || isTelegramAvailable || isWeChatAvailable);
    return [
      MxcButton.secondaryWhite(
        key: const ValueKey('telegramButton'),
        icon: MxcIcons.telegram,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: isTelegramAvailable
            ? () => Navigator.of(context).push(
                  route.featureDialog(
                    TelegramRecoveryPhrasePage(
                      settingsFlow: settingsFlow,
                    ),
                  ),
                )
            : null,
        edgeType: getPageButtonsEdge(),
      ),
      MxcButton.secondaryWhite(
        key: const ValueKey('wechatButton'),
        icon: MxcIcons.wechat,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap: isWeChatAvailable
            ? () => Navigator.of(context).push(
                  route.featureDialog(
                    WechatRecoveryPhrasePage(
                      settingsFlow: settingsFlow,
                    ),
                  ),
                )
            : null,
        edgeType: getPageButtonsEdge(),
      ),
      MxcButton.secondaryWhite(
        key: const ValueKey('emailButton'),
        icon: MxcIcons.email,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'email_secured_storage'),
        onTap: isEmailAvailable
            ? () => Navigator.of(context).push(
                  route.featureDialog(
                    EmailRecoveryPhrasePage(
                      settingsFlow: settingsFlow,
                    ),
                  ),
                )
            : null,
        edgeType: getPageButtonsEdge(),
      ),
      isNoneAvailable
          ? MxcButton.secondaryWhite(
              key: const ValueKey('localButton'),
              icon: Icons.file_download_rounded,
              iconSize: 32,
              titleSize: 18,
              title: FlutterI18n.translate(context, 'local_secured_storage'),
              onTap: () => Navigator.of(context).push(
                route.featureDialog(
                  LocalRecoveryPhrasePage(
                    settingsFlow: settingsFlow,
                  ),
                ),
              ),
              edgeType: getPageButtonsEdge(),
            )
          : Container(),
      MxcButton.secondaryWhite(
        key: const ValueKey('GoogleDriveButton'),
        icon: MxcIcons.google_drive,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'google_drive_secured_storage'),
        onTap: () => Navigator.of(context).push(
          route.featureDialog(
            GoogleDriveRecoveryPhrasePage(
              settingsFlow: settingsFlow,
            ),
          ),
        ),
        edgeType: getPageButtonsEdge(),
      ),
      Platform.isIOS
          ? MxcButton.secondaryWhite(
              key: const ValueKey('icloudButton'),
              icon: MxcIcons.icloud,
              iconSize: 32,
              titleSize: 18,
              title: FlutterI18n.translate(context, 'icloud_secured_storage'),
              onTap: () => Navigator.of(context).push(
                route.featureDialog(
                  ICloudRecoveryPhrasePage(
                    settingsFlow: settingsFlow,
                  ),
                ),
              ),
              edgeType: getPageButtonsEdge(),
            )
          : Container()
    ];
  }
}
