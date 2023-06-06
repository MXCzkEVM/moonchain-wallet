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

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _walletUseCase = ref.read(walletUseCaseProvider);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FlSharedLink().receiveHandler(
          onOpenUrl: (IOSOpenUrlModel? data) => receiveFile(data?.url),
          onIntent: (AndroidIntentModel? data) => receiveFile(data?.id));
    });
  }

  void receiveFile(String? filePath) async {
    if (_authUseCase.loggedIn) return;

    try {
      if (filePath == null || filePath.isEmpty) return;

      String? file = await (Platform.isAndroid
          ? FlSharedLink().getRealFilePathWithAndroid(filePath)
          : FlSharedLink().getAbsolutePathWithIOS(filePath));

      String? mnemonic = await readMnemonicFile(file);

      if (mnemonic != null && mnemonic.isNotEmpty) {
        _walletUseCase.setupFromMnemonic(mnemonic);

        pushPasscodeSetPage();
      } else {
        throw UnimplementedError('Mnemonic file is empty or not exists');
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void pushPasscodeSetPage() =>
      appNavigatorKey.currentState?.pushReplacement(route(
        const PasscodeSetPage(),
      ));

  Future<String?> readMnemonicFile(String? filePath) async {
    if (filePath != null) {
      return await File(filePath).readAsString();
    }

    return null;
  }
}
