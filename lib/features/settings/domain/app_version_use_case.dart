import 'dart:io';

import 'package:android_metadata/android_metadata.dart';
import 'package:datadashwallet/app/configuration.dart';
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
  static const downloadLink =
      'https://datadash.oss-accelerate.aliyuncs.com/axs-wallet.apk';

  Future<bool> checkAppVersionCode() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currrentVersion = packageInfo.buildNumber;

      final result = await repository.appVersionRepository.checkLatestVersion(
        Sys.appSecretAndroid!,
        Sys.distributionGroupIdAndroid!,
        currrentVersion,
      );

      return result;
    } catch (e) {
      debugPrint('checkAppVersionCode: $e');
    }

    return false;
  }

  Future<void> checkLatestVersion() async {
    if (Platform.isIOS) return;

    final metaData = await AndroidMetadata.metaDataAsMap;
    if (metaData == null || metaData['CHANNEL'] != 'product') return;

    final result = await checkAppVersionCode();
    if (!result) return;

    UpdateModel model = UpdateModel(
      downloadLink,
      apkName,
      smallIcon,
      Urls.iOSUrl,
    );

    AzhonAppUpdate.update(model)
        .then((value) => debugPrint('app update progress: $value'));
  }
}
