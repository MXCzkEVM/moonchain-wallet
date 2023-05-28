import 'dart:io';

import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:fl_shared_link/fl_shared_link.dart';
import 'package:flutter/material.dart';

final fileListenerWrapperContainer =
    PresenterContainer<FileListenerWrapperPresenter, void>(
        () => FileListenerWrapperPresenter());

class FileListenerWrapperPresenter extends CompletePresenter<void> {
  FileListenerWrapperPresenter() : super(null);

  IOSUniversalLinkModel? universalLink;
  IOSOpenUrlModel? openUrl;
  Map? launchingOptionsWithIOS;
  AndroidIntentModel? intent;

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isIOS) {
        universalLink = await FlSharedLink().universalLinkWithIOS;
        openUrl = await FlSharedLink().openUrlWithIOS;
        launchingOptionsWithIOS = await FlSharedLink().launchingOptionsWithIOS;
      } else {
        intent = await FlSharedLink().intentWithAndroid;
      }

      FlSharedLink().receiveHandler(
          onUniversalLink: (IOSUniversalLinkModel? data) {
        universalLink = data;
      }, onOpenUrl: (IOSOpenUrlModel? data) {
        openUrl = data;
      }, onIntent: (AndroidIntentModel? data) async {
        String? filePath =
            await FlSharedLink().getRealFilePathWithAndroid(data?.id ?? '');
        String? mnemonic = await readMnemoniceFile(filePath);

        if (mnemonic != null) {
          _walletUseCase.setupFromMnemonic(mnemonic);

          openPasscodeSetPage();
        }
      });
    });
  }

  void openPasscodeSetPage() => appNavigatorKey.currentState?.pushReplacement(
        route(
          const PasscodeSetPage(),
        ),
      );

  Future<String?> readMnemoniceFile(String? filePath) async {
    if (filePath != null) {
      return await File(filePath).readAsString();
    }

    return null;
  }
}
