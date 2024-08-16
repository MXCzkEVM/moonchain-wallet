import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:clipboard/clipboard.dart';

import 'package:datadashwallet/app/logger.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';

import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';

import 'open_dapp.dart';

final openDAppPageContainer =
    PresenterContainer<OpenDAppPresenter, OpenDAppState>(
        () => OpenDAppPresenter());

class OpenDAppPresenter extends CompletePresenter<OpenDAppState> {
  OpenDAppPresenter() : super(OpenDAppState());

  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _customTokensUseCase = ref.read(customTokensUseCaseProvider);
  late final _errorUseCase = ref.read(errorUseCaseProvider);
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final _backgroundFetchConfigUseCase =
      ref.read(backgroundFetchConfigUseCaseProvider);
  late final _bluetoothUseCase = ref.read(bluetoothUseCaseProvider);

  Timer? characteristicListenerTimer;
  StreamSubscription<List<int>>? characteristicValueStreamSubscription;

  MinerHooksHelper get minerHooksHelper => MinerHooksHelper(
        translate: translate,
        context: context,
        dAppHooksUseCase: _dAppHooksUseCase,
        accountUseCase: _accountUseCase,
        backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase,
      );

  JsChannelHandlersHelper get jsChannelHandlersHelper =>
      JsChannelHandlersHelper(
        translate: translate,
        context: context,
        state: state,
        addError: addError,
      );

  CronHelper get cronHelper => CronHelper(
        translate: translate,
        context: context,
        dAppHooksUseCase: _dAppHooksUseCase,
        minerHooksHelper: minerHooksHelper,
        navigator: navigator,
        state: state,
      );

  BluetoothHelper get bluetoothHelper => BluetoothHelper(
        translate: translate,
        context: context,
        collectLog: collectLog,
        minerHooksHelper: minerHooksHelper,
        navigator: navigator,
        state: state,
        loading: (bool value) => loading = value,
        bluetoothUseCase: _bluetoothUseCase,
        characteristicListenerTimer: characteristicListenerTimer,
        characteristicValueStreamSubscription:
            characteristicValueStreamSubscription,
      );

  CronListenersHelper get cronListenersHelper => CronListenersHelper(
        context: context,
        state: state,
        cronHelper: cronHelper,
        jsChannelHandlerHelper: jsChannelHandlersHelper,
      );

  BluetoothListenersHelper get bluetoothListenersHelper =>
      BluetoothListenersHelper(
        translate: translate,
        context: context,
        bluetoothHelper: bluetoothHelper,
        minerHooksHelper: minerHooksHelper,
        jsChannelHandlerHelper: jsChannelHandlersHelper,
        navigator: navigator,
        state: state,
      );

  BridgeFunctionsHelper get bridgeFunctionsHelper => BridgeFunctionsHelper(
        translate: translate,
        context: context,
        state: state,
        addError: addError,
        chainConfigurationUseCase: _chainConfigurationUseCase,
        tokenContractUseCase: _tokenContractUseCase,
        transactionHistoryUseCase: _transactionHistoryUseCase,
        customTokensUseCase: _customTokensUseCase,
        loading: (bool value) => loading = value,
        navigator: navigator,
      );

  BridgeHelper get bridgeHelper => BridgeHelper(
        translate: translate,
        context: context,
        state: state,
        addError: addError,
        addMessage: addMessage,
        authUseCase: _authUseCase,
        chainConfigurationUseCase: _chainConfigurationUseCase,
        errorUseCase: _errorUseCase,
        tokenContractUseCase: _tokenContractUseCase,
        bridgeFunctionsHelper: bridgeFunctionsHelper,
        loading: (bool value) => loading = value,
        notify: notify,
      );

  @override
  void initState() {
    super.initState();

    listen(
      _accountUseCase.account,
      (value) {
        notify(() => state.account = value);
      },
    );

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
      }
    });

    listen(_bluetoothUseCase.scanResults, (value) {
      notify(() => state.scanResults = value);
    });

    listen(_bluetoothUseCase.isScanning, (value) {
      notify(() => state.isBluetoothScanning = value);
    });

    listen(_dAppHooksUseCase.dappHooksData, (value) {
      notify(() => state.dappHooksData = value);
    });
  }

  @override
  Future<void> dispose() {
    cancelCharacteristicListenerTimer();
    closeBlueberryConnection();
    return super.dispose();
  }

  // Disconnects from Blueberry If there a selected device.
  void closeBlueberryConnection() {
    state.selectedScanResult?.device.disconnect();
  }

  void onWebViewCreated(InAppWebViewController controller) async {
    notify(() => state.webviewController = controller);
    updateCurrentUrl(null);
    cronListenersHelper.injectMinerDappListeners();
    bluetoothListenersHelper.injectBluetoothListeners();
  }

  void updateCurrentUrl(Uri? value) async {
    value = value ?? await state.webviewController!.getUrl();
    notify(
      () => state.currentUrl = value,
    );
    checkForUrlSecurity(value);
  }

  void copyUrl() {
    FlutterClipboard.copy(state.currentUrl.toString()).then((value) => null);

    showSnackBar(context: context!, content: translate('copied') ?? '');
  }

  void checkForUrlSecurity(Uri? value) {
    if (value == null) return;
    final isSecure = value.scheme == 'https';
    notify(
      () => state.isSecure = isSecure,
    );
  }

  void changeProgress(int progress) => notify(() => state.progress = progress);

  void copy(List<dynamic> params) {
    Clipboard.setData(ClipboardData(text: params[0]));
  }

  Future<String> paste(List<dynamic> params) async {
    return (await Clipboard.getData('text/plain'))?.text.toString() ?? '';
  }

  void injectCopyHandling() {
    state.webviewController!
        .evaluateJavascript(source: JSChannelScripts.clipboardHandlerScript);
    state.webviewController!.addJavaScriptHandler(
      handlerName: JSChannelEvents.axsWalletCopyClipboard,
      callback: (args) {
        copy(args);
      },
    );
  }

  bool isAddress(String address) {
    return Validation.isAddress(address);
  }

  void launchAddress(String address) {
    _launcherUseCase.viewAddress(address);
  }

  Future<NavigationActionPolicy?> checkDeepLink(
      InAppWebViewController inAppWebViewController,
      NavigationAction navigationAction) async {
    final url = await state.webviewController?.getUrl();
    final deepLink = navigationAction.request.url;

    if (deepLink != null &&
        url != navigationAction.request.url &&
        (deepLink.scheme != 'https' && deepLink.scheme != 'http')) {
      _launcherUseCase.launchUrlInExternalApp(deepLink);
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  injectScrollDetector() {
    state.webviewController!
        .evaluateJavascript(source: JSChannelScripts.overScrollScript);

    state.webviewController!.addJavaScriptHandler(
      handlerName: JSChannelEvents.axsWalletScrollDetector,
      callback: (args) {
        if (args[0] is bool) {
          args[0] == true ? showPanel() : hidePanel();
        }
      },
    );
  }

  Timer? panelTimer;

  void showPanel() => PanelUtils.showPanel(state, panelTimer);

  void hidePanel() => PanelUtils.hidePanel(state, panelTimer);

  void signTransaction({
    required BridgeParams bridge,
    required VoidCallback cancel,
    required Function(String idHaethClientsh) success,
    required String url,
  }) async =>
      bridgeHelper.signTransaction(
        bridge: bridge,
        cancel: cancel,
        success: success,
        url: url,
      );

  void switchEthereumChain(dynamic id, Map<dynamic, dynamic> params) async =>
      bridgeHelper.switchEthereumChain(
        id,
        params,
      );

  void addEthereumChain(dynamic id, Map<dynamic, dynamic> params) async =>
      bridgeHelper.addEthereumChain(
        id,
        params,
      );

  void signMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async =>
      bridgeHelper.signMessage(
        object: object,
        cancel: cancel,
        success: success,
      );

  void signPersonalMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async =>
      bridgeHelper.signPersonalMessage(
        object: object,
        cancel: cancel,
        success: success,
      );

  void signTypedMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async =>
      bridgeHelper.signTypedMessage(
        object: object,
        cancel: cancel,
        success: success,
      );

  void setAddress(dynamic id) => bridgeHelper.setAddress(
        id,
      );

  void switchDefaultNetwork(int id, Network toNetwork, String rawChainId) =>
      bridgeHelper.switchDefaultNetwork(
        id,
        toNetwork,
        rawChainId,
      );

  void addAsset(int id, Map<String, dynamic> data,
          {required VoidCallback cancel,
          required Function(String status) success}) async =>
      bridgeHelper.addAsset(
        id,
        data,
        cancel: cancel,
        success: success,
      );

  void setChain(int? id) => bridgeHelper.setChain(id);

  void closedApp() {
    navigator!.pop();
  }

  DateTime doubleTapTime = DateTime.now();

  void resetDoubleTapTime() {
    doubleTapTime = DateTime.now();
  }

  void showNetworkDetailsBottomSheet() {
    showNetworkDetailsDialog(context!, network: state.network!);
  }

  void detectDoubleTap() {
    final now = DateTime.now();
    final difference = now.difference(doubleTapTime);

    if (difference.inMilliseconds > Config.dAppDoubleTapLowerBound &&
        difference.inMilliseconds < Config.dAppDoubleTapUpperBound) {
      state.webviewController!.reload();
      resetDoubleTapTime();
    } else {
      resetDoubleTapTime();
    }
  }

  void changeOnLoadStopCalled() =>
      state.isLoadStopCalled = !state.isLoadStopCalled;

  void injectAXSWalletJSChannel() =>
      JSChannelUtils.injectAXSWalletJSChannel(state);

  void cancelCharacteristicListenerTimer() =>
      characteristicListenerTimer?.cancel();
}
