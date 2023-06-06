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

  late final _authUseCase = ref.read(authUseCaseProvider);
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
          onUniversalLink: (IOSUniversalLinkModel? data) {},
          onOpenUrl: (IOSOpenUrlModel? data) =>
              readMnemonicFileAndNextPage(data?.url),
          onIntent: (AndroidIntentModel? data) =>
              readMnemonicFileAndNextPage(data?.id));
    });
  }

  void readMnemonicFileAndNextPage(String? filePath) async {
    if (_authUseCase.loggedIn) return;

    try {
      if (filePath == null || filePath.isEmpty) return;

      String? file = await (Platform.isAndroid
          ? FlSharedLink().getRealFilePathWithAndroid(filePath)
          : FlSharedLink().getAbsolutePathWithIOS(filePath));

      String? mnemonic = await readMnemonicFile(file);

      if (mnemonic != null && mnemonic.isNotEmpty) {
        _walletUseCase.setupFromMnemonic(mnemonic);

        openPasscodeSetPage();
      } else {
        throw UnimplementedError('Mnemonic file is empty or not exists');
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void openPasscodeSetPage() => appNavigatorKey.currentState?.pushReplacement(
        route(
          const PasscodeSetPage(),
        ),
      );

  Future<String?> readMnemonicFile(String? filePath) async {
    if (filePath != null) {
      return await File(filePath).readAsString();
    }

    return null;
  }
}
