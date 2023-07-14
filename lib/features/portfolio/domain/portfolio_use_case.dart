import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class PortfolioUseCase extends ReactiveUseCase {
  PortfolioUseCase(this._repository);

  final Web3Repository _repository;

  Future<String> getWalletNativeTokenBalance(String address) async {
    final wallet = await (await _repository.contract).getEthBalance(address);
    return (wallet.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(2);
  }

  void subscribeToBalance(
      String event, void Function(dynamic) listeningCallBack) async {
    _repository.contract.subscribeToBalanceEvent(event, listeningCallBack);
  }

  // Future<List<Token>> getTokensBalanceByAddress(List<Token> tokenList) async {
  //   return (await _repository.contract.getTokensBalance(tokenList));
  // }
}
