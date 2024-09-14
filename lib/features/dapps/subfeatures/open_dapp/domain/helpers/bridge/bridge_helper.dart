import 'dart:convert';

import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/src/providers/providers.dart';
import 'package:moonchain_wallet/features/common/common.dart';

import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';

import '../../../../../../settings/subfeatures/chain_configuration/domain/domain.dart';
import '../../../open_dapp.dart';

class BridgeHelper {
  BridgeHelper({
    required this.tokenContractUseCase,
    required this.chainConfigurationUseCase,
    required this.authUseCase,
    required this.errorUseCase,
    required this.bridgeFunctionsHelper,
    required this.state,
    required this.context,
    required this.translate,
    required this.addError,
    required this.loading,
    required this.notify,
    required this.addMessage,
  });

  OpenDAppState state;
  TokenContractUseCase tokenContractUseCase;
  ChainConfigurationUseCase chainConfigurationUseCase;
  AuthUseCase authUseCase;
  ErrorUseCase errorUseCase;
  BridgeFunctionsHelper bridgeFunctionsHelper;
  BuildContext? context;
  String? Function(String) translate;
  void Function(bool v) loading;
  void Function(dynamic error, [StackTrace? stackTrace]) addError;
  void Function([void Function()? fun]) notify;
  void Function(dynamic message) addMessage;

  void signTransaction({
    required BridgeParams bridge,
    required VoidCallback cancel,
    required Function(String idHaethClientsh) success,
    required String url,
  }) async {
    final amountEther = EtherAmount.inWei(bridge.value ?? BigInt.zero);
    final amount = amountEther.getValueInUnit(EtherUnit.ether).toString();
    final bridgeData = MXCType.hexToUint8List(bridge.data ?? '');
    EtherAmount? gasPrice;
    double? gasFee;
    TransactionGasEstimation? estimatedGasFee;
    BigInt? amountOfGas;

    if (bridge.gasPrice != null) {
      gasPrice = EtherAmount.fromBase10String(EtherUnit.wei, bridge.gasPrice!);
    }

    if (bridge.gas != null) {
      amountOfGas = BigInt.parse(bridge.gas.toString());
      gasPrice = gasPrice ?? await tokenContractUseCase.getGasPrice();
      final gasPriceDouble =
          gasPrice.getValueInUnit(EtherUnit.ether).toDouble();
      gasFee = gasPriceDouble * amountOfGas.toDouble();

      estimatedGasFee = TransactionGasEstimation(
          gasPrice: gasPrice, gas: amountOfGas, gasFee: gasFee);
    } else {
      estimatedGasFee = await bridgeFunctionsHelper.estimatedFee(
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
        loading(true);

        final hash = await bridgeFunctionsHelper.sendTransaction(
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
      loading(false);
    }
  }

  void switchEthereumChain(dynamic id, Map<dynamic, dynamic> params) async {
    final rawChainId = params["object"]["chainId"] as String;
    final chainId = MXCFormatter.hexToDecimal(rawChainId);
    final networks = chainConfigurationUseCase.networks.value;
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

  void addEthereumChain(dynamic id, Map<dynamic, dynamic> params) async {
    final networkDetails = AddEthereumChain.fromMap(params["object"]);

    final rawChainId = networkDetails.chainId;
    final chainId = MXCFormatter.hexToDecimal(rawChainId);
    final networks = chainConfigurationUseCase.networks.value;
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
          ? bridgeFunctionsHelper.updateNetwork(network, foundChainIdIndex)
          : bridgeFunctionsHelper.addNewNetwork(network),
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

  void signMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async {
    final hexData = object['data'] as String;
    String message = MXCType.hexToString(hexData);
    int chainId = state.network!.chainId;
    String name = state.network!.label ?? state.network!.symbol;

    try {
      final result = await showSignMessageDialog(
        context!,
        title: translate('signature_request')!,
        message: message,
        networkName: '$name ($chainId)',
      );

      if (result != null && result) {
        final hash = bridgeFunctionsHelper.signMessage(
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

  void signPersonalMessage({
    required Map<String, dynamic> object,
    required VoidCallback cancel,
    required Function(String hash) success,
  }) async {
    final hexData = object['data'] as String;
    String message = MXCType.hexToString(hexData);
    int chainId = state.network!.chainId;
    String name = state.network!.label ?? state.network!.symbol;

    try {
      final result = await showSignMessageDialog(
        context!,
        title: translate('signature_request')!,
        message: message,
        networkName: '$name ($chainId)',
      );

      if (result != null && result) {
        final hash = bridgeFunctionsHelper.signPersonalMessage(
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
        final hash = bridgeFunctionsHelper.signTypedMessage(
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

  void setAddress(dynamic id) {
    if (state.account != null) {
      final walletAddress = state.account!.address;
      state.webviewController?.setAddress(walletAddress, id);
    }
  }

  void switchDefaultNetwork(int id, Network toNetwork, String rawChainId) {
    // "{"id":1692336424091,"name":"switchEthereumChain","object":{"chainId":"0x66eed"},"network":"ethereum"}"
    chainConfigurationUseCase.switchDefaultNetwork(toNetwork);
    authUseCase.resetNetwork(toNetwork);
    loadDataDashProviders(toNetwork);
    notify(() => state.network = toNetwork);

    setChain(id);
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
        final res = bridgeFunctionsHelper.addAsset(Token(
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

  void callErrorHandler(dynamic e, StackTrace s) {
    final isHandled = errorUseCase.handleError(
      context!,
      e,
      addError,
      translate,
    );
    if (!isHandled) {
      addError(e, s);
    }
  }

  void setChain(int? id) {
    state.webviewController
        ?.setChain(getProviderConfig(), state.network!.chainId, id);
  }

  void cancelRequest(int id) {
    state.webviewController?.cancel(id);
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

  String getProviderConfig() {
    return JSChannelScripts.walletProviderInfoScript(state.network!.chainId,
        state.network!.web3RpcHttpUrl, state.account!.address);
  }
}
