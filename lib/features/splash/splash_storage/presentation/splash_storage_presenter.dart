import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'widgets/confirm_storage_dialog.dart';

final splashStorageContainer =
    PresenterContainer<SplashStoragePresenter, SplashBaseState>(
        () => SplashStoragePresenter());

class SplashStoragePresenter extends SplashBasePresenter<SplashBaseState> {
  SplashStoragePresenter() : super(SplashBaseState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  final AppinioSocialShare _socialShare = AppinioSocialShare();
  final _mnemonicTitle = 'DataDash Wallet Mnemonic Key';
  final _mnemonicFileName =
      '${DateFormat('y-M-d').format(DateTime.now())}-datadash-key.txt';

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  Future<String> writeToFile(
    dynamic content,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final fullPath = '${tempDir.path}/$_mnemonicFileName';
    File file = await File(fullPath).create();
    await file.writeAsString(content);
    return file.path;
  }

  void shareToTelegram() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    showSaveToAppDialog(keys);

    if (Platform.isAndroid) {
      await _socialShare.shareToTelegram(
        _mnemonicTitle,
        filePath: filePath,
      );
    } else {
      _socialShare.shareToSystem(
        _mnemonicTitle,
        '',
        filePath: filePath,
      );
    }

    _walletUseCase.setupFromMnemonic(keys);
  }

  void shareToWechat() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    showSaveToAppDialog(keys, type: StorageType.wechat);

    if (Platform.isAndroid) {
      _socialShare.shareToWechat(
        _mnemonicTitle,
        filePath: filePath,
      );
    } else {
      _socialShare.shareToSystem(
        _mnemonicTitle,
        '',
        filePath: filePath,
      );
    }
  }

  void showSaveToAppDialog(String keys,
      {StorageType type = StorageType.others}) {
    showConfirmStorageAlertDialog(context!, type: type, onOkTap: () {
      _walletUseCase.setupFromMnemonic(keys);

      pushPasscodeSetPage(context!);
    });
  }

  void sendEmail() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    final email = MailOptions(
      body: FlutterI18n.translate(context!, 'email_secured_body'),
      subject: FlutterI18n.translate(context!, 'email_secured_subject'),
      attachments: [filePath],
      isHTML: false,
    );

    await FlutterMailer.send(email);
  }
}
