import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'recovery_phrase_base_state.dart';

abstract class RecoveryPhraseBasePresenter<T extends RecoveryPhraseBaseState>
    extends CompletePresenter<T> {
  RecoveryPhraseBasePresenter(T state) : super(state);

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  final AppinioSocialShare _socialShare = AppinioSocialShare();
  final _mnemonicTitle = 'DataDash Wallet Mnemonic Key';
  final _mnemonicFileName =
      '${DateFormat('y-M-d').format(DateTime.now())}-datadash-key.txt';

  @override
  void initState() {
    super.initState();
  }

  void changeAcceptAggreement() =>
      notify(() => state.acceptAgreement = !state.acceptAgreement);

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
    final phrases = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(phrases);

    if (Platform.isAndroid) {
      await _socialShare.shareToTelegram(
        _mnemonicTitle,
        filePath: filePath,
      );
    } else {
      await _socialShare.shareToSystem(
        _mnemonicTitle,
        '',
        filePath: filePath,
      );
    }

    pushSecurityNoticePage(context!, phrases);
  }

  void shareToWechat() async {
    final phrases = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(phrases);

    if (Platform.isAndroid) {
      await _socialShare.shareToWechat(
        _mnemonicTitle,
        filePath: filePath,
      );
    } else {
      await _socialShare.shareToSystem(
        _mnemonicTitle,
        '',
        filePath: filePath,
      );
    }

    pushSecurityNoticePage(context!, phrases);
  }

  void sendEmail(BuildContext ctx) async {
    final phrases = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(phrases);

    final email = MailOptions(
      body: FlutterI18n.translate(ctx, 'email_secured_body'),
      subject: FlutterI18n.translate(ctx, 'email_secured_subject'),
      attachments: [filePath],
      isHTML: false,
    );

    await FlutterMailer.send(email);

    pushSecurityNoticePage(ctx, phrases);
  }
}
