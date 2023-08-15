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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_authUseCase.loggedIn) return;

      if (Platform.isAndroid) {
        final intent = await FlSharedLink().intentWithAndroid;

        if (intent != null && intent.id != null) {
          final realPath =
              await FlSharedLink().getRealFilePathWithAndroid(intent.id!);

          receiveFile(realPath);
        }
      } else {
        final openUrl = await FlSharedLink().openUrlWithIOS;

        if (openUrl?.url != null) {
          receiveFile(openUrl?.url);
        }
      }

      FlSharedLink().receiveHandler(
          onOpenUrl: (IOSOpenUrlModel? data) => listenReceiveFile(data?.url),
          onIntent: (AndroidIntentModel? data) => listenReceiveFile(data?.id));
    });
  }

  void listenReceiveFile(String? filePath) async {
    try {
      if (filePath == null || filePath.isEmpty) {
        throw UnimplementedError('Mnemonic file is empty or not exists');
      }

      String? realPath = await (Platform.isAndroid
          ? FlSharedLink().getRealFilePathWithAndroid(filePath)
          : FlSharedLink().getAbsolutePathWithIOS(filePath));

      receiveFile(realPath);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void receiveFile(String? filePath) async {
    loading = true;
    try {
      if (filePath == null || filePath.isEmpty) {
        throw UnimplementedError('Mnemonic file is empty or not exists');
      }

      String? mnemonic = await readMnemonicFile(filePath);

      if (mnemonic != null && mnemonic.isNotEmpty) {
        if (_authUseCase.validateMnemonic(mnemonic)) {
          _authUseCase.createWallet(mnemonic);

          pushPasscodeSetPage();
        } else {
          throw UnimplementedError('Mnemonic format is invalid.');
        }
      } else {
        throw UnimplementedError('Mnemonic file is empty or not exists.');
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
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
