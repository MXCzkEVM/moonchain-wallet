import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class FrontEndRequiredHelper {
  FrontEndRequiredHelper({
    required this.state,
    required this.context,
    required this.jsChannelHandlerHelper,
  });

  OpenDAppState state;
  BuildContext? context;
  JsChannelHandlersHelper jsChannelHandlerHelper;

  void injectFrontEndRequiredListeners() {
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.getCookies,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args, handleGetCookies));
  }

  Future<Map<String, dynamic>> handleGetCookies(Map<String, dynamic> data) async {
    collectLog('handleGetCookies : $data');

    final host = data['url'];

    CookieManager cookieManager = CookieManager.instance();
    final allCookies =
        await cookieManager.getCookies(url: WebUri('https://$host/'));

    final cookies = 
      allCookies
          .where((e) {
            collectLog("handleGetCookies:e.domain ${e.domain ?? ""}");
            return (e.domain?.contains(host) ?? false) && e.isHttpOnly == true;
          }) // Exclude HttpOnly cookies
          .map((e) =>
              e.toMap()) // Convert each cookie to a JSON-serializable map
          .toList(); // Convert the iterable to a list

    collectLog("handleGetCookies:cookies $cookies");

    return {'cookies': cookies};
  }
}
