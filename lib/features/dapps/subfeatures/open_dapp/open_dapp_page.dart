import 'package:datadashwallet/app/logger.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:web3_provider/web3_provider.dart';
import 'open_dapp_presenter.dart';
import 'open_dapp_state.dart';
import 'widgets/bridge_params.dart';
import 'widgets/allow_multiple_gestures.dart';

class OpenAppPage extends HookConsumerWidget {
  const OpenAppPage({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openDAppPageContainer.actions);
    final state = ref.watch(openDAppPageContainer.state);
    const primaryVelocity = 2000;
    return Scaffold(
      backgroundColor: ColorsTheme.of(context).screenBackground,
      body: SafeArea(
        child: PresenterHooks(
          presenter: presenter,
          child: Stack(
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  AllowMultipleHorizontalDrag:
                      GestureRecognizerFactoryWithHandlers<
                          AllowMultipleHorizontalDrag>(
                    () => AllowMultipleHorizontalDrag(),
                    (AllowMultipleHorizontalDrag instance) {
                      instance.onEnd = (details) async {
                        final webViewController = state.webviewController!;
                        if (details.primaryVelocity! < 0 - primaryVelocity &&
                            (await webViewController.canGoForward())) {
                          webViewController.goForward();
                          return;
                        }

                        if (details.primaryVelocity! > primaryVelocity &&
                            (await webViewController.canGoBack())) {
                          webViewController.goBack();
                          return;
                        }

                        if (details.primaryVelocity! > primaryVelocity &&
                            !(await webViewController.canGoBack())) {
                          if (BottomFlowDialog.maybeOf(context) != null) {
                            BottomFlowDialog.of(context).close();
                          }
                        }
                      };
                    },
                  ),
                  AllowMultipleDoubleTap: GestureRecognizerFactoryWithHandlers<
                      AllowMultipleDoubleTap>(
                    () => AllowMultipleDoubleTap(),
                    (AllowMultipleDoubleTap instance) {
                      instance.onDoubleTap =
                          () => state.webviewController!.reload();
                    },
                  )
                },
                child: InAppWebViewEIP1193(
                  chainId: state.network?.chainId,
                  rpcUrl: state.network?.web3RpcHttpUrl,
                  walletAddress: state.account!.address,
                  isDebug: false,
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(url),
                  ),
                  onLoadStop: (controller, url) {
                    presenter.injectCopyHandling();
                  },
                  onLoadError: (controller, url, code, message) =>
                      collectLog('onLoadError: $code: $message'),
                  onLoadHttpError: (controller, url, statusCode, description) =>
                      collectLog('onLoadHttpError: $description'),
                  onConsoleMessage: (controller, consoleMessage) => collectLog(
                      'onConsoleMessage: ${consoleMessage.toString()}'),
                  onWebViewCreated: (controller) =>
                      presenter.onWebViewCreated(controller),
                  onProgressChanged: (controller, progress) async {
                    presenter.changeProgress(progress);
                    presenter.setChain(null);
                  },
                  signCallback: (params, eip1193, controller) async {
                    final id = params['id'];
                    switch (eip1193) {
                      case EIP1193.requestAccounts:
                        presenter.setAddress(id);
                        break;
                      case EIP1193.signTransaction:
                        Map<String, dynamic> object = params['object'];
                        BridgeParams bridge = BridgeParams.fromJson(object);
                        presenter.signTransaction(
                            bridge: bridge,
                            cancel: () {
                              controller?.cancel(id);
                            },
                            success: (idHash) {
                              controller?.sendResult(idHash, id);
                            },
                            url: url);
                        break;
                      case EIP1193.signMessage:
                        break;
                      case EIP1193.signPersonalMessage:
                        break;
                      case EIP1193.signTypedMessage:
                        Map<String, dynamic> object = params["object"];
                        presenter.signTypedMessage(
                          object: object,
                          cancel: () {
                            controller?.cancel(id);
                          },
                          success: (idHash) {
                            controller?.sendResult(idHash, id);
                          },
                        );
                        break;
                      case EIP1193.switchEthereumChain:
                        presenter.switchEthereumChain(id, params);
                        break;
                      case EIP1193.addEthereumChain:
                        presenter.addEthereumChain(id, params);
                        break;
                      case EIP1193.watchAsset:
                        presenter.addAsset(
                          id,
                          params['object'],
                          cancel: () {
                            controller?.cancel(id);
                          },
                          success: (idHash) {
                            controller?.sendResult(idHash, id);
                          },
                        );
                        break;
                      case EIP1193.unKnown:
                        break;
                      default:
                        break;
                    }
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false),
                    android: AndroidInAppWebViewOptions(
                      useWideViewPort: true,
                      geolocationEnabled: true,
                      useHybridComposition: true,
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    ),
                  ),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),
                    Factory<HorizontalDragGestureRecognizer>(
                      () => HorizontalDragGestureRecognizer(),
                    ),
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT,
                    );
                  },
                  androidOnGeolocationPermissionsHidePrompt: (controller) {},
                  androidOnGeolocationPermissionsShowPrompt:
                      (InAppWebViewController controller, String origin) async {
                    return GeolocationPermissionShowPromptResponse(
                        origin: origin, allow: true, retain: true);
                  },
                ),
              ),
              if (state.progress != 100)
                LinearProgressIndicator(
                  value: state.progress / 100,
                  color: Colors.greenAccent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
