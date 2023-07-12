import 'dart:async';
import 'dart:math';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class ContractUseCase extends ReactiveUseCase {
  ContractUseCase(this._repository);

  final ApiRepository _repository;

  late final ValueStream<bool> online = reactive(false);

  late final ValueStream<List<Token>> tokensList = reactive([]);

  Future<String> getWalletNativeTokenBalance(EthereumAddress address) async {
    final balance = await _repository.contract.getEthBalance(address);
    return (balance.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(2);
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
    final result = await _repository.contract.getDefaultTokens();
    if (result != null) {
      tokensList.value.addAll(result.tokens ?? []);
      update(tokensList, tokensList.value);
    }
    return result;
  }

  Future<Token?> getToken(String address) async =>
      await _repository.contract.getToken(address);

  Future<String> getName(String address) async =>
      await _repository.contract.getName(address);

  Future<void> checkConnectionToNetwork() async {
    final result = await _repository.contract.checkConnectionToNetwork();

    update(online, result);
  }

  Future<void> getTokensBalance() async {
    final result = await _repository.contract.getTokensBalance(
        tokensList.value, _repository.address.getLocalstoragePublicAddress()!);
    update(tokensList, result);
  }

  void addCustomTokens(List<Token> customTokens) {
    tokensList.value.addAll(customTokens);
    update(tokensList, tokensList.value);
  }
}
