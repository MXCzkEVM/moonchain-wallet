import 'dart:convert';
import 'dart:io';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/secured_storage/secured_storage.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_extend/share_extend.dart';
import 'package:social_share/appinio_social_share.dart';

import 'secured_storage_page_state.dart';

final securedStoragePageContainer =
    PresenterContainer<SecuredStoragePagePresenter, SecuredStoragePageState>(
        () => SecuredStoragePagePresenter());

class SecuredStoragePagePresenter
    extends CompletePresenter<SecuredStoragePageState> {
  SecuredStoragePagePresenter() : super(SecuredStoragePageState());

  late final WalletUseCase _walletUseCase = ref.read(walletUseCaseProvider);
  final AppinioSocialShare _socialShare = AppinioSocialShare();

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  Future<String> writeToFile(
    dynamic content,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final fullPath = '${tempDir.path}/DataDash_Mnemonice.txt';
    final data = jsonEncode(content);
    File file = await File(fullPath).create();
    await file.writeAsString(data);
    return file.path;
  }

  Future<void> isInstallApps() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }

  void shareToTelegram() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    await _socialShare.shareToTelegram(
      'DataDash Wallet Mnemonice Phrase',
      filePath: filePath,
    );
  }

  void shareToWechat() async {
    Navigator.of(context!).push(route(const PasscodeSetPage()));
    return;
    SaveToHereTip().show(context!);

    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    _socialShare.shareToWechat(
      'DataDash Wallet Mnemonice Phrase',
      filePath: filePath,
    );
  }
}
