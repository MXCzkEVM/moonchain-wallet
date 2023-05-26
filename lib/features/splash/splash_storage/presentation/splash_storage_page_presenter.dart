import 'dart:convert';
import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


final splashStoragePageContainer =
    PresenterContainer<SplashStoragePagePresenter, SplashStoragePageState>(
        () => SplashStoragePagePresenter());

class SplashStoragePagePresenter
    extends SplashBasePagePresenter<SplashStoragePageState> {
  SplashStoragePagePresenter() : super(SplashStoragePageState());

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  final AppinioSocialShare _socialShare = AppinioSocialShare();

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  Future<String> writeToFile(
    dynamic content,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final fullPath = '${tempDir.path}/DataDash_Mnemonice.txt';
    final data = jsonEncode(content);
    File file = await File(fullPath).create();
    await file.writeAsString(data);
    return file.path;
  }

  Future<void> isInstallApps() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }

  void shareToTelegram() async {
    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    await _socialShare.shareToTelegram(
      'DataDash Wallet Mnemonice Phrase',
      filePath: filePath,
    );
  }

  void shareToWechat() async {
    // Navigator.of(context!).push(route(const PasscodeSwitchBiometricPage()));
    return;
    SaveToHereTip().show(context!);

    final keys = _walletUseCase.generateMnemonic();
    final filePath = await writeToFile(keys);

    _socialShare.shareToWechat(
      'DataDash Wallet Mnemonice Phrase',
      filePath: filePath,
    );
  }
}
