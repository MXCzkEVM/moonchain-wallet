import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:url_launcher/url_launcher.dart';

final splashImportStorageContainer =
    PresenterContainer<SplashImportStoragePresenter, SplashBaseState>(
        () => SplashImportStoragePresenter());

class SplashImportStoragePresenter
    extends SplashBasePresenter<SplashBaseState> {
  SplashImportStoragePresenter() : super(SplashBaseState());

  late final _launcherUseCase = ref.read(launcherUseCaseProvider);

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() => openUrl(_launcherUseCase.openTelegram);

  void openWechat() => openUrl(_launcherUseCase.openWeChat);

  void openEmail() async {
    try {
      final result = await OpenMailApp.openMailApp();

      if (!result.didOpen && !result.canOpen) {
        throw Exception('Could not find any mail app.');
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    }
  }

  void openUrl(Function launcherFunction) async {
    loading = true;

    try {
      launcherFunction();
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      loading = false;
    }
  }
}
