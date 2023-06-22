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

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() => openUrl('tg://');

  void openWechat() => openUrl('weixin://');

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

  void openUrl(String url) async {
    final uri = Uri.parse(url);
    loading = true;

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw UnimplementedError('Could not launch $url');
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      loading = false;
    }
  }
}
