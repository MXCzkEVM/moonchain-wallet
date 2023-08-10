import 'dart:async';

import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

extension Unique<E, T> on List<E> {
  void unique([T Function(E element)? id, bool inPlace = true]) {
    final ids = <dynamic>{};
    var list = inPlace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as T));
  }
}

class TokenContractUseCase extends ReactiveUseCase {
  TokenContractUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  late final ValueStream<bool> online = reactive(false);

  late final ValueStream<List<Token>> tokensList = reactive([]);

  late final ValueStream<String?> name = reactive();

  Future<String> getWalletNativeTokenBalance(String address) async {
    final balance = await _repository.tokenContract.getEthBalance(address);
    return Formatter.convertWeiToEth(balance.getInWei.toString());
  }

  void subscribeToBalance(
      String event, void Function(dynamic) listeningCallBack) async {
    _repository.tokenContract.subscribeToBalanceEvent(event, listeningCallBack);
  }

  Future<WannseeTransactionsModel?> getTransactionsByAddress(
      String address) async {
    return _repository.tokenContract.getTransactionsByAddress(address);
  }

  Future<WannseeTransactionModel?> getTransactionByHash(String hash) async {
    return _repository.tokenContract.getTransactionByHash(hash);
  }

  Future<WannseeTokenTransfersModel?> getTokenTransfersByAddress(
      String address) async {
    return _repository.tokenContract.getTokenTransfersByAddress(address);
  }

  Future<DefaultTokens?> getDefaultTokens(String walletAddress) async {
    final result = await _repository.tokenContract.getDefaultTokens();
    final mxcBalance = await getWalletNativeTokenBalance(walletAddress);

    final mxcToken = Token(
      logoUri:
          'https://raw.githubusercontent.com/MXCzkEVM/wannseeswap-tokenlist/main/assets/mxc.svg',
      balance: double.parse(mxcBalance),
      symbol: 'MXC',
      name: 'MXC Token',
    );

    tokensList.value.clear();
    tokensList.value.add(mxcToken);

    if (result != null) {
      tokensList.value.addAll(result.tokens!);
    }

    update(tokensList, tokensList.value);
    return result;
  }

  Future<Token?> getToken(String address) async =>
      await _repository.tokenContract.getToken(address);

  Future<String> getName(String address) async {
    final result = await _repository.tokenContract.getName(address);
    update(name, result);
    return result;
  }

  Future<String> getAddress(String? name) async =>
      await _repository.tokenContract.getAddress(name);

  Future<void> checkConnectionToNetwork() async {
    final result = await _repository.tokenContract.checkConnectionToNetwork();

    update(online, result);
  }

  Future<void> getTokensBalance(String walletAddress) async {
    final result = await _repository.tokenContract
        .getTokensBalance(tokensList.value, walletAddress);
    update(tokensList, result);
  }

  void addCustomTokens(List<Token> customTokens) {
    tokensList.value.addAll(customTokens);
    tokensList.value.unique((token) => token.address);

    update(tokensList, tokensList.value);
  }

  Future<EtherAmount> getGasPrice() async =>
      await _repository.tokenContract.getGasPrice();

  Future<EstimatedGasFee> estimateGesFee({
    required String from,
    required String to,
    EtherAmount? gasPrice,
    Uint8List? data,
  }) async =>
      await _repository.tokenContract.estimateGesFee(
        from: from,
        to: to,
        gasPrice: gasPrice,
        data: data,
      );

  Future<String> sendTransaction({
    required String privateKey,
    required String to,
    required String amount,
    EstimatedGasFee? estimatedGasFee,
    Uint8List? data,
  }) async =>
      await _repository.tokenContract.sendTransaction(
        privateKey: privateKey,
        to: to,
        amount: amount,
        estimatedGasFee: estimatedGasFee,
        data: data,
      );

  Future<int> getChainId(String rpcUrl) async {
    return await _repository.tokenContract.getChainId(rpcUrl);
  }

  Future<DefaultTweets> getDefaultTweets() async {
    return await _repository.tokenContract.getDefaultTweets();
  }
}
