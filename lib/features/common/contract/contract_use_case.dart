import 'dart:async';

import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

extension Unique<E, T> on List<E> {
  void unique([T Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as T));
  }
}

class ContractUseCase extends ReactiveUseCase {
  ContractUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  late final ValueStream<bool> online = reactive(false);

  late final ValueStream<List<Token>> tokensList = reactive([]);

  Future<String> getWalletNativeTokenBalance(String address) async {
    final balance = await _repository.contract.getEthBalance(address);
    return Formatter.convertWeiToEth(balance.getInWei.toString());
  }

  void subscribeToBalance(
      String event, void Function(dynamic) listeningCallBack) async {
    _repository.contract.subscribeToBalanceEvent(event, listeningCallBack);
  }

  Future<WannseeTransactionsModel?> getTransactionsByAddress(
      String address) async {
    return _repository.contract.getTransactionsByAddress(address);
  }

  Future<WannseeTransactionModel?> getTransactionByHash(String hash) async {
    return _repository.contract.getTransactionByHash(hash);
  }

  Future<WannseeTokenTransfersModel?> getTokenTransfersByAddress(
      String address) async {
    return _repository.contract.getTokenTransfersByAddress(address);
  }

  Future<DefaultTokens?> getDefaultTokens(String walletAddress) async {
    final result = await _repository.contract.getDefaultTokens();
    final mxcBalance = await getWalletNativeTokenBalance(walletAddress);
    final mxcToken = Token(
      logoUri:
          'https://raw.githubusercontent.com/MXCzkEVM/wannseeswap-tokenlist/main/assets/mxc.svg',
      balance: double.parse(mxcBalance),
      symbol: 'MXC',
      name: 'MXC Token',
    );

    tokensList.value.add(mxcToken);

    if (result != null) {
      tokensList.value.addAll(result.tokens ?? []);
      tokensList.value.unique((x) => x.address);
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

  Future<void> getTokensBalance(String walletAddress) async {
    final result = await _repository.contract
        .getTokensBalance(tokensList.value, walletAddress);
    update(tokensList, result);
  }

  void addCustomTokens(List<Token> customTokens) {
    tokensList.value.addAll(customTokens);
    tokensList.value.unique((x) => x.address);

    update(tokensList, tokensList.value);
  }
}
