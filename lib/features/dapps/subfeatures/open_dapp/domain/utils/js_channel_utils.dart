import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../open_dapp.dart';

class JSChannelUtils {
  static void injectMXCWalletJSChannel(OpenDAppState state) async {
    // Making It easy for accessing axs wallet
    // use this way window.axs.callHandler
    // It was moved to web3 provider package to inject ad document start
    // await state.webviewController!.evaluateJavascript(
    //     source: JSChannelScripts.axsWalletObjectInjectScript(
    //         JSChannelConfig.axsWalletJSObjectName));

    // await state.webviewController!.injectJavascriptFileFromAsset(
    //     assetFilePath: 'assets/js/bluetooth/bluetooth.js');

    // There is a gap for detecting the axs object in webview, It's intermittent after adding function structure to the scripts
    Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        await state.webviewController!.evaluateJavascript(
            source: JSChannelScripts.axsWalletReadyInjectScript(
          JSChannelEvents.axsReadyEvent,
        ));
      },
    );
  }

  static Future<String> loadJSBluetoothScript(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/js/bluetooth/bluetooth.js');
  }
}
