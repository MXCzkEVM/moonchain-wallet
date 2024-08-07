import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class CronListenersHelper {
  CronListenersHelper(
      {required this.state,
      required this.context,
      required this.jsChannelHandlerHelper,
      required this.cronHelper});

  OpenDAppState state;
  BuildContext? context;
  JsChannelHandlersHelper jsChannelHandlerHelper;
  CronHelper cronHelper;

  // call this on webview created
  void injectMinerDappListeners() async {
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.changeCronTransitionEvent,
        callback: (args) => jsChannelHandlerHelper.jsChannelCronErrorHandler(
            args, cronHelper.handleChangeCronTransition));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.changeCronTransitionStatusEvent,
        callback: (args) => jsChannelHandlerHelper.jsChannelCronErrorHandler(
            args, cronHelper.handleChangeCronTransitionStatusEvent));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.getSystemInfoEvent,
        callback: (args) => jsChannelHandlerHelper.jsChannelCronErrorHandler(
            args, cronHelper.handleGetSystemInfoEvent));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.goToAdvancedSettingsEvent,
        callback: (args) => jsChannelHandlerHelper.jsChannelCronErrorHandler(
            args, cronHelper.handleGoToAdvancedSettingsEvent));
  }
}
