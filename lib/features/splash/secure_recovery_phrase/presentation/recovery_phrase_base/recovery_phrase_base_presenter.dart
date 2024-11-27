import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'recovery_phrase_base_state.dart';

abstract class RecoveryPhraseBasePresenter<T extends RecoveryPhraseBaseState>
    extends CompletePresenter<T> {
  RecoveryPhraseBasePresenter(T state) : super(state);

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _googleDriveUseCase = ref.read(googleDriveUseCaseProvider);
  late final _iCloudUseCase = ref.read(iCloudUseCaseProvider);

  final AppinioSocialShare _socialShare = AppinioSocialShare();
  final _mnemonicTitle = 'Moonchain Wallet Mnemonic Key';
  final _mnemonicFileName = Assets.seedPhaseFileName;

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

  Future<Map> generateMnemonicFile(bool settingsFlow) async {
    final phrases = getMnemonic(settingsFlow);
    final filePath = await writeToFile(phrases);

    return {
      'filePath': filePath,
      'phrases': phrases,
    };
  }

  void nextProcess(bool settingsFlow, String phrases) async {
    if (settingsFlow) {
      BottomFlowDialog.of(context!).close();
      return;
    }

    await createAccount(phrases);
    pushSecurityNoticePage(context!);
  }

  Future<void> createAccount(String phrases) async {
    final account = await _authUseCase.addAccount(phrases);
    _accountUseCase.addAccount(account);
  }

  void shareToTelegram(bool settingsFlow) async {
    final res = await generateMnemonicFile(settingsFlow);

    if (Platform.isAndroid) {
      await _socialShare.android.shareToTelegram(
        _mnemonicTitle,
        res['filePath'],
      );
    } else {
      await _socialShare.iOS.shareToSystem(
        _mnemonicTitle,
        filePaths: [res['filePath']],
      );
    }

    nextProcess(settingsFlow, res['phrases']);
  }

  void shareToWechat(bool settingsFlow) async {
    final res = await generateMnemonicFile(settingsFlow);

    if (Platform.isAndroid) {
      await _socialShare.android.shareToWechat(
        _mnemonicTitle,
        res['filePath'],
      );
    } else {
      await _socialShare.iOS.shareToSystem(
        _mnemonicTitle,
        filePaths: [
          res['filePath'],
        ],
      );
    }

    nextProcess(settingsFlow, res['phrases']);
  }

  void sendEmail(
    BuildContext ctx,
    bool settingsFlow,
    String userEmail,
  ) async {
    final res = await generateMnemonicFile(settingsFlow);

    final email = MailOptions(
      body: translate('email_secured_body')!,
      subject: translate('email_secured_subject')!,
      attachments: [res['filePath']],
      isHTML: false,
      recipients: [userEmail],
    );

    try {
      bool canSend = await FlutterMailer.canSendMail();

      if (Platform.isIOS && !canSend) {
        await _launcherUseCase.launchEmailApp();
      } else {
        MailerResponse sendResult = await FlutterMailer.send(email);
        // only [ios] can return sent | saved | cancelled
        // [android] will return android there is no way of knowing on android
        // if the intent was sent saved or even cancelled.
        if (MailerResponse.cancelled != sendResult) {
          nextProcess(settingsFlow, res['phrases']);
        }
      }
    } catch (e, s) {
      if (e == 'unable_to_launch_email_app') {
        addError(translate('unable_to_launch_email_app'));
      } else {
        addError(e, s);
      }
    }
  }

  void saveLocally(bool settingsFlow) async {
    final mnemonic = getMnemonic(settingsFlow);

    await _authUseCase.saveMnemonicLocally(mnemonic);
    nextProcess(settingsFlow, mnemonic);
  }

  Future<void> saveToGoogleDrive(bool settingsFlow) async {
    loading = true;
    final mnemonic = getMnemonic(settingsFlow);

    // Trying to pass the auth headers to google drive use case for further api calls
    final hasGoogleDriveAccess =
        await _googleDriveUseCase.initGoogleDriveAccess();

    if (!hasGoogleDriveAccess) {
      addError(translate('unable_to_authenticate_with_x')!
          .replaceFirst('{0}', translate('google_drive')!));
    }

    try {
      await _googleDriveUseCase.uploadBackup(mnemonic);
      nextProcess(settingsFlow, mnemonic);
    } catch (e) {
      addError(translate('unable_to_upload_backup_to_x')!
          .replaceFirst('{0}', translate('google_drive')!));
      collectLog(e.toString());
    } finally {
      loading = false;
    }
  }

  Future<void> saveToICloud(bool settingsFlow) async {
    loading = true;
    final mnemonic = getMnemonic(settingsFlow);

    try {
      await Future.delayed(const Duration(seconds: 5));
      await _iCloudUseCase.uploadBackup(mnemonic);
      nextProcess(settingsFlow, mnemonic);
    } catch (e) {
      addError(translate('unable_to_upload_backup_to_x')!
          .replaceFirst('{0}', translate('icloud')!));
      collectLog(e.toString());
    } finally {
      loading = false;
    }
  }

  String getMnemonic(bool settingsFlow) => settingsFlow
      ? _accountUseCase.getMnemonic()!
      : _authUseCase.generateMnemonic();
}
