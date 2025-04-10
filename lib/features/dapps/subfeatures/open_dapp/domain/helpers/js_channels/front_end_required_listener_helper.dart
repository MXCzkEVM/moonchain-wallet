import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class FrontEndRequiredListenerHelper {
  FrontEndRequiredListenerHelper(
      {required this.state,
      required this.context,
      required this.jsChannelHandlerHelper,
      required this.frontEndRequiredHelper});

  OpenDAppState state;
  BuildContext? context;
  JsChannelHandlersHelper jsChannelHandlerHelper;
  FrontEndRequiredHelper frontEndRequiredHelper;

  // call this on webview created
  void injectFrontEndRequiredListeners() {
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.getCookies,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args, frontEndRequiredHelper.handleGetCookies));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.scanQRCodeEvent,
        callback: (args) => frontEndRequiredHelper.handleScanQRCode(context));
  }
}
