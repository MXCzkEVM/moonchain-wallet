import 'package:mxc_logic/mxc_logic.dart';

import '../../open_dapp.dart';

class JSChannelUtils {
  static void injectMXCWalletJSChannel(OpenDAppState state) async {
    // Making It easy for accessing axs wallet
    // use this way window.axs.callHandler
    await state.webviewController!.evaluateJavascript(
        source: JSChannelScripts.axsWalletObjectInjectScript(
            JSChannelConfig.axsWalletJSObjectName));

    await state.webviewController!.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/js/bluetooth/bluetooth.js');

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
}
