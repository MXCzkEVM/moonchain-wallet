import 'dart:collection';

import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wallet_connect/wallet_connect.dart';

import 'open_app_presenter.dart';
import 'open_app_state.dart';

class OpenAppPage extends HookConsumerWidget {
  const OpenAppPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openAppPageContainer.actions(url));
    final state = ref.watch(openAppPageContainer.state(url));

    return Scaffold(
      body: PresenterHooks(
        presenter: presenter,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              useShouldInterceptAjaxRequest: true,
              javaScriptCanOpenWindowsAutomatically: true,
              javaScriptEnabled: true,
              useOnLoadResource: true,
              useShouldInterceptFetchRequest: true,
            ),
          ),
        ),

        // WebView(
        //         initialUrl:
        //             url,
        //         backgroundColor: ColorsTheme.of(context).primaryBackground,
        //         javascriptMode: JavascriptMode.unrestricted,
        //         javascriptChannels: {
        //           JavascriptChannel(
        //             name: 'Captcha',
        //             onMessageReceived: (JavascriptMessage msg) async {
        //             },
        //           ),
        //         },
        //         // onPageFinished: ref.read(actions).onPageFinished,

        //       ),

        // WebViewWidget(
        //   controller: state.webViewController
        //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
        //     ..setBackgroundColor(ColorsTheme.of(context).primaryBackground)
        //     ..loadRequest(Uri.parse(url)),
        // ),
      ),
    );
  }
}
