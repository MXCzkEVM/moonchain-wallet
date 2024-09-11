import 'dart:io';

import 'package:moonchain_wallet/app/app.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:fl_shared_link/fl_shared_link.dart';
import 'package:flutter/material.dart';

final fileListenerWrapperContainer =
    PresenterContainer<FileListenerWrapperPresenter, void>(
        () => FileListenerWrapperPresenter());

class FileListenerWrapperPresenter extends CompletePresenter<void> {
  FileListenerWrapperPresenter() : super(null);

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _flSharedLink = FlSharedLink();

  void checkImportFile(
    AppLifecycleState current,
  ) async {
    if (current == AppLifecycleState.resumed) {
      _flSharedLink.receiveHandler(
          onOpenUrl: (IOSOpenUrlModel? data) => listenReceiveFile(data?.url),
          onIntent: (AndroidIntentModel? data) => listenReceiveFile(data?.id));
    }
  }

  void listenReceiveFile(String? filePath) async {
    if (_authUseCase.loggedIn) return;

    try {
      if (filePath == null || filePath.isEmpty) {
        throw UnimplementedError('Mnemonic file is empty or not exists');
      }

      String? realPath = await (Platform.isAndroid
          ? _flSharedLink.getRealFilePathWithAndroid(filePath)
          : _flSharedLink.getAbsolutePathWithIOS(filePath));

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
          final account = await _authUseCase.addAccount(mnemonic);
          _accountUseCase.addAccount(account);

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

  void pushPasscodeSetPage() => appNavigatorKey.currentState?.replaceAll(route(
        const PasscodeSetPage(),
      ));

  Future<String?> readMnemonicFile(String? filePath) async {
    if (filePath != null) {
      return await File(filePath).readAsString();
    }

    return null;
  }
}
