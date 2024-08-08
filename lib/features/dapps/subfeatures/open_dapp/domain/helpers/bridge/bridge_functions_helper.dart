import 'dart:typed_data';

import 'package:datadashwallet/common/components/components.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/add_token/domain/custom_tokens_use_case.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class BridgeFunctionsHelper {
  BridgeFunctionsHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.navigator,
    required this.customTokensUseCase,
    required this.tokenContractUseCase,
    required this.transactionHistoryUseCase,
    required this.chainConfigurationUseCase,
    required this.addError,
    required this.loading,
  });

  OpenDAppState state;
  TokenContractUseCase tokenContractUseCase;
  CustomTokensUseCase customTokensUseCase;
  TransactionsHistoryUseCase transactionHistoryUseCase;
  ChainConfigurationUseCase chainConfigurationUseCase;
  NavigatorState? navigator;
  BuildContext? context;
  String? Function(String) translate;
  void Function(bool v) loading;
  void Function(dynamic error, [StackTrace? stackTrace]) addError;

  Future<TransactionGasEstimation?> estimatedFee(
    String from,
    String to,
    EtherAmount? gasPrice,
    Uint8List data,
    BigInt? amountOfGas,
  ) async {
    loading(true);
    try {
      final gasFee = await tokenContractUseCase.estimateGasFeeForContractCall(
          from: from,
          to: to,
          gasPrice: gasPrice,
          data: data,
          amountOfGas: amountOfGas);
      loading(false);

      return gasFee;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading(false);
    }
  }

  Future<String?> sendTransaction(String to, EtherAmount amount,
      Uint8List? data, TransactionGasEstimation? estimatedGasFee, String url,
      {String? from}) async {
    final res = await tokenContractUseCase.sendTransaction(
        privateKey: state.account!.privateKey,
        to: to,
        from: from,
        amount: amount,
        data: data,
        estimatedGasFee: estimatedGasFee);
    if (!MXCChains.isMXCChains(state.network!.chainId)) {
      recordTransaction(res);
    }

    return res.hash;
  }

  String? signMessage(
    String hexData,
  ) {
    loading(true);
    try {
      final res = tokenContractUseCase.signMessage(
          privateKey: state.account!.privateKey, message: hexData);
      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading(false);
    }
  }

  String? signPersonalMessage(
    String hexData,
  ) {
    loading(true);
    try {
      final res = tokenContractUseCase.signPersonalMessage(
          privateKey: state.account!.privateKey, message: hexData);
      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading(false);
    }
  }

  String? signTypedMessage(
    String hexData,
  ) {
    loading(true);
    try {
      final res = tokenContractUseCase.signTypedMessage(
          privateKey: state.account!.privateKey, data: hexData);
      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading(false);
    }
  }

  bool addAsset(Token token) {
    loading(true);
    try {
      customTokensUseCase.addItem(token);
      return true;
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return false;
    } finally {
      loading(false);
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

    transactionHistoryUseCase.spyOnTransaction(
      tx,
    );
    transactionHistoryUseCase.updateItem(
      tx,
    );
  }

  Network? updateNetwork(Network network, int index) {
    chainConfigurationUseCase.updateItem(network, index);
    return network;
  }

  Network? addNewNetwork(Network newNetwork) {
    chainConfigurationUseCase.addItem(newNetwork);
    return newNetwork;
  }
}
