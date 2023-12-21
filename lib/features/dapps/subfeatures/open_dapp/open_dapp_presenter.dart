import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/domain/dapps_errors.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/add_asset_dialog.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/swtich_network_dialog.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/typed_message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:eth_sig_util/util/utils.dart';

import 'open_dapp_state.dart';
import 'widgets/bridge_params.dart';
import 'widgets/transaction_dialog.dart';

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
  }

  void onWebViewCreated(InAppWebViewController controller) async {
    notify(() => state.webviewController = controller);
    updateCurrentUrl(null);
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

  Future<TransactionGasEstimation?> _estimatedFee(
    String from,
    String to,
    EtherAmount? gasPrice,
    Uint8List data,
    BigInt? amountOfGas,
  ) async {
    loading = true;
    try {
      final gasFee = await _tokenContractUseCase.estimateGasFeeForContractCall(
          from: from,
          to: to,
          gasPrice: gasPrice,
          data: data,
          amountOfGas: amountOfGas);
      loading = false;

      return gasFee;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  Future<String?> _sendTransaction(String to, EtherAmount amount,
      Uint8List? data, TransactionGasEstimation? estimatedGasFee, String url,
      {String? from}) async {
    final res = await _tokenContractUseCase.sendTransaction(
        privateKey: state.account!.privateKey,
        to: to,
        from: from,
        amount: amount,
        data: data,
        estimatedGasFee: estimatedGasFee);
    if (!Config.isMxcChains(state.network!.chainId)) {
      recordTransaction(res);
    }

    return res.hash;
  }

  String? _signTypedMessage(
    String hexData,
  ) {
    loading = true;
    try {
      final res = _tokenContractUseCase.signTypedMessage(
          privateKey: state.account!.privateKey, data: hexData);
      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  bool _addAsset(Token token) {
    loading = true;
    try {
      _customTokensUseCase.addItem(token);
      return true;
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return false;
    } finally {
      loading = false;
    }
  }

  void recordTransaction(TransactionModel tx) {
    // final timeStamp = DateTime.now();
    // const txStatus = TransactionStatus.pending;
    // const txType = TransactionType.contractCall;
    final currentNetwork = state.network!;
    final chainId = currentNetwork.chainId;
    final token = Token(
      chainId: currentNetwork.chainId,
      logoUri: currentNetwork.logo,
      name: currentNetwork.label ?? currentNetwork.web3RpcHttpUrl,
      symbol: currentNetwork.symbol,
      address: null,
    );

    tx = tx.copyWith(token: token);
    // final tx = TransactionModel(
    //   hash: hash,
    //   timeStamp: timeStamp,
    //   status: txStatus,
    //   type: txType,
    //   value: null,
    //   token: token,
    //   action: null,
    // );

    _transactionHistoryUseCase.spyOnTransaction(
      tx,
    );
    _transactionHistoryUseCase.updateItem(
      tx,
    );
  }

  void signTransaction({
    required BridgeParams bridge,
    required VoidCallback cancel,
    required Function(String idHaethClientsh) success,
    required String url,
  }) async {
    final amountEther = EtherAmount.inWei(bridge.value ?? BigInt.zero);
    final amount = amountEther.getValueInUnit(EtherUnit.ether).toString();
    final bridgeData = hexToBytes(bridge.data ?? '');
    EtherAmount? gasPrice;
    double? gasFee;
    TransactionGasEstimation? estimatedGasFee;
    BigInt? amountOfGas;

    if (bridge.gasPrice != null) {
      gasPrice = EtherAmount.fromBase10String(EtherUnit.wei, bridge.gasPrice!);
    }

    if (bridge.gas != null) {
      amountOfGas = BigInt.parse(bridge.gas.toString());
      gasPrice = gasPrice ?? await _tokenContractUseCase.getGasPrice();
      final gasPriceDouble =
          gasPrice.getValueInUnit(EtherUnit.ether).toDouble();
      gasFee = gasPriceDouble * amountOfGas.toDouble();

      estimatedGasFee = TransactionGasEstimation(
          gasPrice: gasPrice, gas: amountOfGas, gasFee: gasFee);
    } else {
      estimatedGasFee = await _estimatedFee(
          bridge.from!, bridge.to!, gasPrice, bridgeData, amountOfGas);

      if (estimatedGasFee == null) {
        cancel.call();
        return;
      }
    }

    String finalFee =
        (estimatedGasFee.gasFee / Config.dappSectionFeeDivision).toString();
    final maxFeeDouble = estimatedGasFee.gasFee * Config.priority;
    final maxFeeString =
        (maxFeeDouble / Config.dappSectionFeeDivision).toString();
    final maxFee =
        Validation.isExpoNumber(maxFeeString) ? '0.000' : maxFeeString;

    if (Validation.isExpoNumber(finalFee)) {
      finalFee = '0.000';
    }

    final symbol = state.network!.symbol;

    try {
      final result = await showTransactionDialog(context!,
          title: translate('confirm_transaction')!,
          amount: amount,
          from: bridge.from!,
          to: bridge.to!,
          estimatedFee: finalFee,
          maxFee: maxFee,
          symbol: symbol);

      if (result != null && result) {
        loading = true;

        final hash = await _sendTransaction(
            bridge.to!, amountEther, bridgeData, estimatedGasFee, url,
            from: bridge.from);
        if (hash != null) success.call(hash);
      } else {
        cancel.call();
      }
    } catch (e, s) {
      cancel.call();
      callErrorHandler(e, s);
    } finally {
      loading = false;
    }
  }

  void callErrorHandler(dynamic e, StackTrace s) {
    final isHandled = _errorUseCase.handleError(
      context!,
      e,
      addError,
      translate,
    );
    if (!isHandled) {
      addError(e, s);
    }
  }

  void switchEthereumChain(dynamic id, Map<dynamic, dynamic> params) async {
    final rawChainId = params["object"]["chainId"] as String;
    final chainId = MXCFormatter.hexToDecimal(rawChainId);
    final networks = _chainConfigurationUseCase.networks.value;
    final foundChainIdIndex =
        networks.indexWhere((element) => element.chainId == chainId);

    if (foundChainIdIndex != -1) {
      final foundNetwork = networks[foundChainIdIndex];
      final res = await showSwitchNetworkDialog(context!,
          fromNetwork: state.network!.label ?? state.network!.web3RpcHttpUrl,
          toNetwork: foundNetwork.label ?? foundNetwork.web3RpcHttpUrl,
          onTap: () {
        switchDefaultNetwork(id, foundNetwork, rawChainId);
      });
      if (!(res ?? false)) {
        cancelRequest(id);
      }
    } else {
      addError(translate('network_not_found'));
      final e =
          DAppErrors.switchEthereumChainErrors.unRecognizedChain(rawChainId);
      sendProviderError(
          id, e['code'], MXCFormatter.escapeDoubleQuotes(e['message']));
    }
  }

  void checkCancel(bool? res, Function moveOn, int id) {
    if (!(res ?? false)) {
      cancelRequest(id);
    } else {
      moveOn();
    }
  }

  void sendProviderError(int id, int code, String message) {
    state.webviewController?.sendProviderError(id, code, message);
  }

  void sendError(String error, int id) {
    state.webviewController
        ?.sendError(MXCFormatter.escapeDoubleQuotes(error), id);
  }

  void cancelRequest(int id) {
    state.webviewController?.cancel(id);
  }

  void unSupportedRequest() {
    addError(translate('network_not_found'));
  }

  void addEthereumChain(dynamic id, Map<dynamic, dynamic> params) async {
    final networkDetails = AddEthereumChain.fromMap(params["object"]);

    final rawChainId = networkDetails.chainId;
    final chainId = MXCFormatter.hexToDecimal(rawChainId);
    final networks = _chainConfigurationUseCase.networks.value;
    final foundChainIdIndex =
        networks.indexWhere((element) => element.chainId == chainId);
    // user can add a network again meaning It will override the old network
    final alreadyExists = foundChainIdIndex != -1;
    final alreadyEnabled =
        alreadyExists ? networks[foundChainIdIndex].enabled : false;

    // Add network
    final newNetwork = Network.fromAddEthereumChain(networkDetails, chainId);

    final res = await showAddNetworkDialog(
      context!,
      network: newNetwork,
      approveFunction: (network) => alreadyExists
          ? updateNetwork(network, foundChainIdIndex)
          : addNewNetwork(network),
    );

    if (!(res ?? false)) {
      cancelRequest(id);
    } else {
      if (!alreadyEnabled) {
        final res = await showSwitchNetworkDialog(context!,
            fromNetwork: state.network!.label ?? state.network!.web3RpcHttpUrl,
            toNetwork: newNetwork.label ?? newNetwork.web3RpcHttpUrl,
            onTap: () {
          switchDefaultNetwork(id, newNetwork, rawChainId);
        });
        if (!(res ?? false)) {
          cancelRequest(id);
        }
      }
    }
  }

  Network? updateNetwork(Network network, int index) {
    _chainConfigurationUseCase.updateItem(network, index);
    return network;
  }

  Network? addNewNetwork(Network newNetwork) {
    _chainConfigurationUseCase.addItem(newNetwork);
    return newNetwork;
  }

  void signPersonalMessage() {}

  void signTypedMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async {
    String hexData = object['raw'] as String;
    Map<String, dynamic> data =
        jsonDecode(object['raw'] as String) as Map<String, dynamic>;
    Map<String, dynamic> domain = data['domain'] as Map<String, dynamic>;
    String primaryType = data['primaryType'];
    int chainId = (domain['chainId']) as int;
    String name = domain['name'] as String;

    try {
      final result = await showTypedMessageDialog(context!,
          title: translate('signature_request')!,
          message: data['message'] as Map<String, dynamic>,
          networkName: '$name ($chainId)',
          primaryType: primaryType);

      if (result != null && result) {
        final hash = _signTypedMessage(
          hexData,
        );
        if (hash != null) success.call(hash);
      } else {
        cancel.call();
      }
    } catch (e, s) {
      cancel.call();
      addError(e, s);
    }
  }

  void changeProgress(int progress) => notify(() => state.progress = progress);

  void setAddress(dynamic id) {
    if (state.account != null) {
      final walletAddress = state.account!.address;
      state.webviewController?.setAddress(walletAddress, id);
    }
  }

  void switchDefaultNetwork(int id, Network toNetwork, String rawChainId) {
    // "{"id":1692336424091,"name":"switchEthereumChain","object":{"chainId":"0x66eed"},"network":"ethereum"}"
    _chainConfigurationUseCase.switchDefaultNetwork(toNetwork);
    _authUseCase.resetNetwork(toNetwork);
    loadDataDashProviders(toNetwork);
    notify(() => state.network = toNetwork);

    setChain(id);
  }

  void setChain(int? id) {
    state.webviewController?.setChain(getConfig(), state.network!.chainId, id);
  }

  String getConfig() {
    return """{
              ethereum: {
                chainId: ${state.network!.chainId},
                rpcUrl: "${state.network!.web3RpcHttpUrl}",
                address: "${state.account!.address}",
                isDebug: true,
                networkVersion: "${state.network!.chainId}",
                isMetaMask: true
              }
            }""";
  }

  void copy(List<dynamic> params) {
    Clipboard.setData(ClipboardData(text: params[0]));
  }

  Future<String> paste(List<dynamic> params) async {
    return (await Clipboard.getData('text/plain'))?.text.toString() ?? '';
  }

  void injectCopyHandling() {
    state.webviewController!.evaluateJavascript(
        source:
            'javascript:navigator.clipboard.writeText = (msg) => { return window.flutter_inappwebview?.callHandler("axs-wallet-copy-clipboard", msg); }');
    state.webviewController!.addJavaScriptHandler(
      handlerName: 'axs-wallet-copy-clipboard',
      callback: (args) {
        copy(args);
      },
    );
  }

  bool isAddress(String address) {
    return Validation.isAddress(address);
  }

  void addAsset(int id, Map<String, dynamic> data,
      {required VoidCallback cancel,
      required Function(String status) success}) async {
    final watchAssetData = WatchAssetModel.fromMap(data);
    String titleText = translate('add_x')
            ?.replaceFirst('{0}', translate('token')?.toLowerCase() ?? '--') ??
        '--';

    try {
      final result = await showAddAssetDialog(
        context!,
        token: watchAssetData,
        title: titleText,
      );

      if (result != null && result) {
        final res = _addAsset(Token(
            decimals: watchAssetData.decimals,
            address: watchAssetData.contract,
            symbol: watchAssetData.symbol,
            chainId: state.network?.chainId));

        if (res) {
          success.call(res.toString());
          addMessage(translate('add_token_success_message'));
        } else {
          cancel.call();
        }
      } else {
        cancel.call();
      }
    } catch (e, s) {
      cancel.call();
      addError(e, s);
    }
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

  final double maxPanelHeight = 100.0;

  final cancelDuration = const Duration(milliseconds: 400);
  final settleDuration = const Duration(milliseconds: 400);

  injectScrollDetector() {
    String jsCode = """
      var pStart = { x: 0, y: 0 };
      var pStop = { x: 0, y: 0 };

      function swipeStart(e) {
        if (typeof e["targetTouches"] !== "undefined") {
          var touch = e.targetTouches[0];
          pStart.x = touch.screenX;
          pStart.y = touch.screenY;
        } else {
          pStart.x = e.screenX;
          pStart.y = e.screenY;
        }
      }

      function swipeEnd(e) {
        if (typeof e["changedTouches"] !== "undefined") {
          var touch = e.changedTouches[0];
          pStop.x = touch.screenX;
          pStop.y = touch.screenY;
        } else {
          pStop.x = e.screenX;
          pStop.y = e.screenY;
        }

        swipeCheck();
      }

      function swipeCheck() {
        var changeY = pStart.y - pStop.y;
        var changeX = pStart.x - pStop.x;
        if (isPullDown(changeY, changeX)) {
          window.flutter_inappwebview?.callHandler("axs-scroll-detector", true);
        } else if (isPullUp(changeY, changeX)) {
          window.flutter_inappwebview?.callHandler("axs-scroll-detector", false);
        }
      }

      function isPullDown(dY, dX) {
        // methods of checking slope, length, direction of line created by swipe action
        console.log(dY);
        console.log(dX );
        return (
          dY < 0 &&
          ((Math.abs(dX) <= 100 && Math.abs(dY) >= 100 ) ||
            (Math.abs(dX) / Math.abs(dY) <= 0.1 && dY >= 60))
        );
      }

      function isPullUp(dY, dX) {
        // Check if the gesture is a pull-up
        console.log(dY);
        console.log(dX);
        return (
          dY > 0 &&
          ((Math.abs(dX) <= 100 && Math.abs(dY) >= 100) ||
            (Math.abs(dX) / Math.abs(dY) <= 0.1 && dY >= 60))
        );
      }

      document.addEventListener(
        "touchstart",
        function (e) {
          swipeStart(e);
        },
        false
      );
      document.addEventListener(
        "touchend",
        function (e) {
          swipeEnd(e);
        },
        false
      );
      """;
    state.webviewController!.evaluateJavascript(source: jsCode);

    state.webviewController!.addJavaScriptHandler(
      handlerName: 'axs-scroll-detector',
      callback: (args) {
        if (args[0] is bool) {
          args[0] == true ? showPanel() : hidePanel();
        }
      },
    );
  }

  Timer? panelTimer;

  void showPanel() async {
    final status = state.animationController!.status;
    if (state.animationController!.value != 1 &&
            status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      await state.animationController!.animateTo(
        1.0,
        duration: settleDuration,
        curve: Curves.ease,
      );
      panelTimer = Timer(const Duration(seconds: 3), hidePanel);
    }
  }

  void hidePanel() async {
    final status = state.animationController!.status;
    if (state.animationController!.value != 0 &&
        status == AnimationStatus.completed) {
      await state.animationController!.animateTo(
        0.0,
        duration: cancelDuration,
        curve: Curves.easeInExpo,
      );
      if (panelTimer != null) {
        panelTimer!.cancel();
      }
    }
  }

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
}
