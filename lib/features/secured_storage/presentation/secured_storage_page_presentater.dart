import 'dart:convert';
import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/secured_storage/secured_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final securedStoragePageContainer =
    PresenterContainer<SecuredStoragePagePresenter, void>(
        () => SecuredStoragePagePresenter());

class SecuredStoragePagePresenter extends CompletePresenter<void> {
  SecuredStoragePagePresenter() : super(null);

  late final WalletUseCase _walletUseCase = ref.read(walletUseCaseProvider);

  Future<String> writeToFile(
    dynamic content,
  ) async {
    final tempPath = await getTemporaryDirectory().then((e) => e.path);
    final fullPath = path.join(tempPath, 'dd.keys');
    final str = jsonEncode(content);
    await File(fullPath).writeAsString(str);
    return path.toUri(fullPath).toString();
  }
  

  void socialShare() async {
    AppinioSocialShare appinioSocialShare = AppinioSocialShare();

    final keys = _walletUseCase.generateMnemonic();
    final storagePath = await writeToFile(keys);
    await appinioSocialShare.shareToSystem(
      'DataDash Wallet Keys',
      keys,
      filePath: storagePath,
    );
  }
}
