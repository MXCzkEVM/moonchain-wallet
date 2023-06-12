import 'package:datadashwallet/core/core.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'open_app_state.dart';

final openAppPageContainer =
    PresenterContainerWithParameter<OpenAppPresenter, OpenAppState, String>(
        (url) => OpenAppPresenter(url));

class OpenAppPresenter extends CompletePresenter<OpenAppState> {
  OpenAppPresenter(this.url) : super(OpenAppState());

  final String url;

  @override
  void initState() {
    super.initState();

    initPage();
  }

  @override
  Future<void> dispose() {
    return super.dispose();
  }

  Future<void> initPage() async {
    // final ChromeSafariBrowser browser = ChromeSafariBrowser();
    // final myxx = InAppBrowser;

    // InAppBrowser.openWithSystemBrowser(url: Uri.parse(url));
    // browser.open(url: Uri.parse(url));
    // await state.webViewController
    //     .setJavaScriptMode(JavaScriptMode.unrestricted);
    // state.webViewController
    //     .setBackgroundColor(ColorsTheme.of(context!).primaryBackground);
    // await state.webViewController.loadRequest(Uri.parse(url));
  }
}
