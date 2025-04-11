import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:flutter/material.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/qr_code/qr_scanner/qr_scanner_page.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../open_dapp.dart';

class FrontEndRequiredHelper {
  FrontEndRequiredHelper({
    required this.state,
    required this.context,
  });

  OpenDAppState state;
  BuildContext? context;

  Future<Map<String, dynamic>> handleScanQRCode(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {

      final isDenied = await PermissionUtils.isPermissionPermanentlyDenied(Permission.camera);
      if (isDenied) {
        throw "Camera permission denied, To enable camera access, please go to your iPhone Settings → "
      "Privacy & Security → Camera → Allow access for MoonBase!";
      }

      final qrCode = await showBaseBottomSheet(
        context: context!,
        hasCloseButton: false,
        content: const QrScannerPage(
          returnQrCode: true,
        ),
      );

      final response = AXSJSChannelResponseModel<Map<String, String>>(
          status: AXSJSChannelResponseStatus.success,
          message: null,
          data: null);

      return response.toMap((qrCode) => {}, mappedData: {'qrCode': qrCode});
  }

  Future<Map<String, dynamic>> handleGetCookies(
      Map<String, dynamic> data, BuildContext? context) async {
    collectLog('handleGetCookies : $data');

    final host = data['url'];

    CookieManager cookieManager = CookieManager.instance();
    final allCookies =
        await cookieManager.getCookies(url: WebUri('https://$host/'));

    // Commented this part is some cases like Pixel 5 API 32 emulator
    // All the properties except name & value are null
    // final cookies
    //   allCookies
    //       .where((e) {
    //         collectLog("handleGetCookies:e.domain ${e.domain ?? ""}");
    //         return (e.domain?.contains(host) ?? false) && e.isHttpOnly == true;
    //       }) // Exclude HttpOnly cookies
    //       .map((e) =>
    //           e.toMap()) // Convert each cookie to a JSON-serializable map
    //       .toList(); // Convert the iterable to a list

    collectLog("handleGetCookies:cookies $allCookies");

    return {'cookies': allCookies};
  }
}
