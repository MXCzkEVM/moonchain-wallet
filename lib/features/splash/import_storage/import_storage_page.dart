import 'dart:io';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
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

  MXCWalletButtonEdgeType getPageButtonsEdge() => MXCWalletButtonEdgeType.hard;

  @override
  List<Widget> setButtons(BuildContext context, WidgetRef ref) {
    final splashBaseState = ref.watch(state);
    final splashBasePresenter = ref.read(presenter);
    final isTelegramAvailable = splashBaseState.applist['telegram'] == true ||
        splashBaseState.applist['telegram_web'] == true;
    final isWeChatAvailable = splashBaseState.applist['weixin'] == true ||
        splashBaseState.applist['we_chat'] == true;
    final isNoneAvailable = !(isTelegramAvailable || isWeChatAvailable);
    return [
      MxcButton.secondaryWhite(
        key: const ValueKey('telegramButton'),
        icon: MxcIcons.telegram,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'telegram_secured_storage'),
        onTap: isTelegramAvailable
            ? () => splashBasePresenter.openTelegram()
            : null,
        edgeType: getPageButtonsEdge(),
      ),
      MxcButton.secondaryWhite(
        key: const ValueKey('wechatButton'),
        icon: MxcIcons.wechat,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'wechat_secured_storage'),
        onTap:
            isWeChatAvailable ? () => splashBasePresenter.openWechat() : null,
        edgeType: getPageButtonsEdge(),
      ),
      MxcButton.secondaryWhite(
        key: const ValueKey('mnemonicButton'),
        icon: MxcIcons.cloud,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'secret_recovery_phrase'),
        onTap: () => Navigator.of(context).push(
          route(
            const SplashImportWalletPage(),
          ),
        ),
        edgeType: getPageButtonsEdge(),
      ),
      MxcButton.secondaryWhite(
        key: const ValueKey('GoogleDriveButton'),
        icon: MxcIcons.google_drive,
        iconSize: 32,
        titleSize: 18,
        title: FlutterI18n.translate(context, 'google_drive_secured_storage'),
        onTap: () => splashBasePresenter.loadBackupFromGoogleDrive(),
        edgeType: getPageButtonsEdge(),
      ),
      Platform.isIOS
          ? MxcButton.secondaryWhite(
              key: const ValueKey('icloudButton'),
              icon: MxcIcons.icloud,
              iconSize: 32,
              titleSize: 18,
              title: FlutterI18n.translate(context, 'icloud_secured_storage'),
              onTap: () => splashBasePresenter.loadBackupFromICloud(),
              edgeType: getPageButtonsEdge(),
            )
          : Container(),
      !isNoneAvailable
          ? MxcButton.secondaryWhite(
              key: const ValueKey('localButton'),
              icon: Icons.file_download_rounded,
              iconSize: 32,
              titleSize: 18,
              title: FlutterI18n.translate(context, 'local_secured_storage'),
              onTap: () => splashBasePresenter.openLocalSeedPhrase(),
              edgeType: getPageButtonsEdge(),
            )
          : Container(),
    ];
  }
}
