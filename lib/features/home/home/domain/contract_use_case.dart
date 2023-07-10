import 'dart:async';
import 'dart:math';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class ContractUseCase extends ReactiveUseCase {
  ContractUseCase(this._repository);

  final ApiRepository _repository;

  Future<String> getWalletNativeTokenBalance(EthereumAddress address) async {
    final wallet = await (await _repository.contract).getEthBalance(address);
    return (wallet.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(2);
  }

  void subscribeToBalance(
      String event, void Function(dynamic) listeningCallBack) async {
    _repository.contract.subscribeToBalanceEvent(event, listeningCallBack);
  }

  Future<WannseeTransactionsModel?> getTransactionsByAddress(
      EthereumAddress address) async {
    return _repository.contract.getTransactionsByAddress(address);
  }

  Future<WannseeTransactionModel?> getTransactionByHash(String hash) async {
    return _repository.contract.getTransactionByHash(hash);
  }

  Future<WannseeTokenTransfersModel?> getTokenTransfersByAddress(
      EthereumAddress address) async {
    return _repository.contract.getTokenTransfersByAddress(address);
  }

  Future<DefaultTokens?> getDefaultTokens() async {
    return _repository.contract.getDefaultTokens();
  }

  Future<Token?> getToken(String address) async =>
      await _repository.contract.getToken(address);
}
