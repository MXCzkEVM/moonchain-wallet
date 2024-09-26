import 'dart:io';

import 'package:android_metadata/android_metadata.dart';
import 'package:moonchain_wallet/app/configuration.dart';
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
      'https://app.xbmxc.com/app/moonchain.apk';

  Future<bool> checkAppVersionCode() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currrentVersion = packageInfo.version;

      final result = await repository.appVersionRepository.checkLatestVersion(
        currrentVersion,
      );

      return result;
    } catch (e) {
      debugPrint('checkAppVersionCode: $e');
    }

    return false;
  }

  Future<void> checkLatestVersion() async {
    debugPrint('Checking latest version...');
    if (Platform.isIOS) {
      debugPrint('Skipping update check for iOS');
      return;
    }

    final metaData = await AndroidMetadata.metaDataAsMap;
    debugPrint('Metadata: $metaData');
    if (metaData == null || metaData['CHANNEL'] != 'product') {
      debugPrint('Skipping update - not on product channel');
      return;
    }

    final result = await checkAppVersionCode();
    debugPrint('Update available: $result');
    if (!result) {
      debugPrint('No update available, exiting');
      return;
    }

    debugPrint('Initiating update process...');
    UpdateModel model = UpdateModel(
      downloadLink,
      apkName,
      smallIcon,
      Urls.iOSUrl,
    );

    try {
      final updateResult = await AzhonAppUpdate.update(model);
      debugPrint('App update progress: $updateResult');
    } catch (e) {
      debugPrint('Error during update process: $e');
    }
  }
}
