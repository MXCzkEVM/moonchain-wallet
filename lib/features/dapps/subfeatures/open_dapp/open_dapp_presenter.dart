import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/domain/dapps_errors.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/add_asset_dialog.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/swtich_network_dialog.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/typed_message_dialog.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/dapp_hooks_page.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
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
  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final _backgroundFetchConfigUseCase =
      ref.read(backgroundFetchConfigUseCaseProvider);

  MinerHooksHelper get minerHooksHelper => MinerHooksHelper(
      translate: translate,
      context: context,
      dAppHooksUseCase: _dAppHooksUseCase,
      accountUseCase: _accountUseCase,
      backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase);

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

    listen(_dAppHooksUseCase.dappHooksData, (value) {
      notify(() => state.dappHooksData = value);
    });
  }

  void onWebViewCreated(InAppWebViewController controller) async {
    notify(() => state.webviewController = controller);
    updateCurrentUrl(null);
    injectMinerDappListeners();
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
    state.webviewController
        ?.setChain(getProviderConfig(), state.network!.chainId, id);
  }

  String getProviderConfig() {
    return JSChannelScripts.walletProviderInfoScript(state.network!.chainId,
        state.network!.web3RpcHttpUrl, state.account!.address);
  }

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

  void changeOnLoadStopCalled() {
    state.isLoadStopCalled = !state.isLoadStopCalled;
  }

  // call this on webview created
  void injectMinerDappListeners() async {
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.changeCronTransitionEvent,
        callback: (args) =>
            jsChannelErrorHandler(args, handleChangeCronTransition));
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.changeCronTransitionStatusEvent,
        callback: (args) =>
            jsChannelErrorHandler(args, handleChangeCronTransitionStatusEvent));
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.getSystemInfoEvent,
        callback: (args) =>
            jsChannelErrorHandler(args, handleGetSystemInfoEvent));
    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.goToAdvancedSettingsEvent,
        callback: (args) =>
            jsChannelErrorHandler(args, handleGoToAdvancedSettingsEvent));
  }

  void injectAXSWalletJSChannel() async {
    // Making It easy for accessing axs wallet
    // use this way window.axs.callHandler
    await state.webviewController!.evaluateJavascript(
        source: JSChannelScripts.axsWalletObjectInjectScript(
            JSChannelConfig.axsWalletJSObjectName));

    await state.webviewController!.evaluateJavascript(
        source: JSChannelScripts.axsWalletReadyInjectScript(
      JSChannelEvents.axsReadyEvent,
    ));
  }

  Future<Map<String, dynamic>> jsChannelErrorHandler(
      List<dynamic> args,
      Future<Map<String, dynamic>> Function(
              Map<String, dynamic>, AXSCronServices)
          callback) async {
    try {
      Map<String, dynamic> channelDataMap;

      final channelData = args[0];
      channelDataMap = channelData as Map<String, dynamic>;

      final axsCronService =
          AXSCronServicesExtension.getCronServiceFromJson(channelDataMap);
      final callbackRes = await callback(channelDataMap, axsCronService);
      return callbackRes;
    } catch (e) {
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.failed,
          data: null,
          message: e.toString());
      return response.toMap((data) => {'message': e.toString()});
    }
  }

  // Update via functions & get data via steam & send the data via event eaach time
  // ready => updateSystemInfo (service statues, mining service status, time, selected miners, camera permission location permission)

  Future<Map<String, dynamic>> handleChangeCronTransition(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    final axsCronService =
        AXSCronServicesExtension.getCronServiceFromJson(channelData);
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      ChangeCronTransitionRequestModel;
      final changeCronTransitionRequestModel =
          ChangeCronTransitionRequestModel<MiningCronServiceDataModel>.fromMap(
              channelData['cron'], MiningCronServiceDataModel.fromMap);

      // Here i change the data that won't effect the
      final currentDappHooksData = state.dappHooksData;
      final newData = changeCronTransitionRequestModel.data;

      if (newData != null) {
        final minersList = newData.minersList ??
            currentDappHooksData.minerHooks.selectedMiners;
        _dAppHooksUseCase.updateMinersList(minersList);

        final newTimeOfDay = TimeOfDay.fromDateTime(newData.time!);
        final currentTimeOfDay =
            TimeOfDay.fromDateTime(currentDappHooksData.minerHooks.time);

        if (newData.time != null && newTimeOfDay != currentTimeOfDay) {
          await minerHooksHelper.changeMinerHookTiming(newTimeOfDay);
        }
      }

      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(
              _dAppHooksUseCase.dappHooksData.value);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService,
          _dAppHooksUseCase.dappHooksData.value,
          miningCronServiceData);

      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.success,
          data: responseData,
          message: null);
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown service';
    }
  }

  Future<Map<String, dynamic>> handleChangeCronTransitionStatusEvent(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      final status = channelData['cron']['status'];

      await minerHooksHelper.changeMinerHooksEnabled(status);
      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(
              _dAppHooksUseCase.dappHooksData.value);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService,
          _dAppHooksUseCase.dappHooksData.value,
          miningCronServiceData);
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.success,
          message: null,
          data: responseData);
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown cron service';
    }
  }

  Future<Map<String, dynamic>> handleGetSystemInfoEvent(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      final dappHooksData = state.dappHooksData;

      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(dappHooksData);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService, dappHooksData, miningCronServiceData);
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
        status: AXSJSChannelResponseStatus.success,
        message: null,
        data: responseData,
      );
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown cron service';
    }
  }

  Future<Map<String, dynamic>> handleGoToAdvancedSettingsEvent(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    goToAdvancedSettings();
    final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
        status: AXSJSChannelResponseStatus.success, message: null, data: null);
    return response.toMap((data) => {});
  }

  void goToAdvancedSettings() {
    navigator!.push(route(
      const DAppHooksPage(),
    ));
  }
}
