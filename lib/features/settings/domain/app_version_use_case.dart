import 'dart:io';

import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/common/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update/flutter_app_update.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionUseCase {
  AppVersionUseCase(
    this.repository,
  );

  final Web3Repository repository;

  static const apkName = 'app-release.apk';
  static const smallIcon = 'ic_launcher';

  Future<String?> checkAppVersionCode() async {
    if (Platform.isIOS) return null;

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currrentVersion = packageInfo.version;

      final appUrl = await repository.appVersionRepository.checkLatestVersion(
        Sys.appSecretAndroid!,
        Sys.distributionGroupIdAndroid!,
        currrentVersion,
      );

      return appUrl;
    } catch (e) {
      print('checkAppVersionCode: $e');
    }
  }

  Future<void> checkLatestVersion() async {
    final updateUrl = await checkAppVersionCode();

    UpdateModel model = UpdateModel(
      updateUrl ?? '',
      apkName,
      smallIcon,
      Urls.iOSUrl,
    );

    AzhonAppUpdate.update(model)
        .then((value) => debugPrint('android apk dwonload progress: $value'));
  }
}
