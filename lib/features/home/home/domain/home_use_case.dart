import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class HomeUseCase extends ReactiveUseCase {
  HomeUseCase(this._repository);

  final ApiRepository _repository;

  Future<String> getWalletNativeTokenBalance(EthereumAddress address) async {
    final wallet = await (await _repository.contract).getEthBalance(address);
    return (wallet.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(2);
  }

  void subscribeToBalance(
      String event, void Function(dynamic) listeningCallBack) async {
    (await _repository.contract)
        .subscribeToBalanceEvent(event, listeningCallBack);
  }

  Future<WannseeTransactionsModel?> getTransactionsByAddress(
      EthereumAddress address) async {
    return (await _repository.contract).getTransactionsByAddress(address);
  }

  Future<WannseeTransactionModel?> getTransactionByHash(String hash) async {
    return (await _repository.contract).getTransactionByHash(hash);
  }

  Future<WannseeTokenTransfersModel?> getTokenTransfersByAddress(
      EthereumAddress address) async {
    return (await _repository.contract).getTokenTransfersByAddress(address);
  }

  Future<DefaultTokens?> getDefaultTokens() async {
    return ((await _repository.contract).getDefaultTokens());
  }

  // Future<Token> getTokenTransfers(){}
}
