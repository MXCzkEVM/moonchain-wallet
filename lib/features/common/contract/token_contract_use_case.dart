import 'dart:async';

import 'package:datadashwallet/common/common.dart';
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

  late final ValueStream<double> totalBalanceInXsd = reactive(0.0);

  Future<String> getWalletNativeTokenBalance(String address) async {
    final balance = await _repository.tokenContract.getEthBalance(address);
    return Formatter.convertWeiToEth(
        balance.getInWei.toString(), Config.ethDecimals);
  }

  Future<Stream<dynamic>?> subscribeToBalance(String event) async {
    return await _repository.tokenContract.subscribeToBalanceEvent(
      event,
    );
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
    return _repository.tokenContract
        .getTokenTransfersByAddress(address, TokenType.erc_20);
  }

  Future<DefaultTokens?> getDefaultTokens(String walletAddress) async {
    final result = await _repository.tokenContract.getDefaultTokens();
    tokensList.value.clear();
    final cNetwork = _repository.tokenContract.getCurrentNetwork();

    final chainNativeToken = Token(
        logoUri: result?.logoUri ?? 'assets/svg/networks/unknown.svg',
        symbol: cNetwork.symbol,
        name: '${cNetwork.symbol} Token',
        decimals: Config.ethDecimals);

    tokensList.value.add(chainNativeToken);

    if (result != null) {
      if (result.tokens != null) {
        tokensList.value.addAll(result.tokens!);
      }
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
    try {
      final result = await _repository.tokenContract
          .getTokensBalance(tokensList.value, walletAddress);
      update(tokensList, result);
      getTokensPrice();
    } catch (e) {
      final newList = [];
      for (Token token in tokensList.value) {
        newList.add(token.copyWith(balance: 0.0));
      }
      update(tokensList, newList);
      getTokensBalance(walletAddress);
    }
  }

  Future<void> getTokensPrice() async {
    final result =
        await _repository.pricingRepository.getTokensPrice(tokensList.value);
    update(tokensList, result);
    calculateTotalBalanceInXsd();
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
    BigInt? amountOfGas,
  }) async =>
      await _repository.tokenContract.estimateGesFee(
          from: from,
          to: to,
          gasPrice: gasPrice,
          data: data,
          amountOfGas: amountOfGas);

  Future<String> sendTransaction({
    required String privateKey,
    required String to,
    String? from,
    required EtherAmount amount,
    EstimatedGasFee? estimatedGasFee,
    Uint8List? data,
  }) async =>
      await _repository.tokenContract.sendTransaction(
        privateKey: privateKey,
        to: to,
        from: from,
        amount: amount,
        estimatedGasFee: estimatedGasFee,
        data: data,
      );

  Future<int> getChainId(String rpcUrl) async {
    return await _repository.tokenContract.getChainId(rpcUrl);
  }

  void calculateTotalBalanceInXsd() {
    double totalPrice = 0.0;
    for (int i = 0; i < tokensList.value.length; i++) {
      final token = tokensList.value[i];
      totalPrice += token.balancePrice!;
    }
    update(totalBalanceInXsd, totalPrice);
  }
}
