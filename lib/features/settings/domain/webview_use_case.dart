import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewUseCase {
  WebviewUseCase();

  Future<void> clearWebStorage() async {
    WebStorageManager webStorageManager = WebStorageManager.instance();

    if (Platform.isAndroid) {
      await webStorageManager.android.deleteAllData();
    } else if (Platform.isIOS) {
      // Available from iOS 9.0+.
      // The IOSWebStorageManager class represents various types of data
      // that a website might make use of.
      // This includes cookies, disk and memory caches,
      // and persistent data such as WebSQL, IndexedDB databases, and local storage.
      final records = await webStorageManager.ios
          .fetchDataRecords(dataTypes: IOSWKWebsiteDataType.values);
      final recordsToDelete = <IOSWKWebsiteDataRecord>[];
      recordsToDelete.addAll(records);
      await webStorageManager.ios.removeDataFor(
          dataTypes: IOSWKWebsiteDataType.values, dataRecords: recordsToDelete);
    }
  }

  Future<void> clearCookie() async {
    // Available from iOS 11.0+.
    CookieManager cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  }

  Future<void> clearCache() async => Future.wait([
        clearWebStorage(),
        clearCookie(),
      ]);
}
