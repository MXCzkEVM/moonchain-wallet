import 'dart:convert';
import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'widgets/confirm_storage_dialog.dart';

final splashStorageContainer =
    PresenterContainer<SplashStoragePresenter, SplashStorageState>(
        () => SplashStoragePresenter());

class SplashStoragePresenter
    extends SplashBasePresenter<SplashStorageState> {
  SplashStoragePresenter() : super(SplashStorageState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  final AppinioSocialShare _socialShare = AppinioSocialShare();
  final _tip = SaveToHereTip();
  final _mnemoniceTitle = 'DataDash Wallet Mnemonice Phrase';
  final _mnemoniceFileName = 'DataDash-Mnemonice.txt';

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  Future<String> writeToFile(
    dynamic content,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final fullPath = '${tempDir.path}/$_mnemoniceFileName';
    File file = await File(fullPath).create();
    await file.writeAsString(content);
    return file.path;
  }

  void shareToTelegram() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    if (Platform.isAndroid) {
      showDialogAndGoToNext(keys);

      await _socialShare.shareToTelegram(
        _mnemoniceTitle,
        filePath: filePath,
      );
    } else {
      showDialogAndGoToNext(keys, useTip: true);

      _socialShare.shareToSystem(
        _mnemoniceTitle,
        '',
        filePath: filePath,
      );
    }

    _walletUseCase.setupFromMnemonic(keys);
  }

  void shareToWechat() async {
    _tip.show(context!);

    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    showDialogAndGoToNext(keys, useTip: true);

    if (Platform.isAndroid) {
      _socialShare.shareToWechat(
        _mnemoniceTitle,
        filePath: filePath,
      );
    } else {
      _socialShare.shareToSystem(
        _mnemoniceTitle,
        '',
        filePath: filePath,
      );
    }
  }

  void showDialogAndGoToNext(String keys, {bool useTip = false}) {
    showConfirmStorageAlertDialog(context!, onOkTap: () {
      _walletUseCase.setupFromMnemonic(keys);
      useTip ? _tip.hide(context!) : null;

      pushPasscodeSetPage(context!);
    }, onNoTap: () {
      useTip ? _tip.hide(context!) : null;
    });
  }
}
