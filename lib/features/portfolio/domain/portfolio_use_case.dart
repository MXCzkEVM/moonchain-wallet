import 'dart:async';
import 'dart:math';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class PortfolioUseCase extends ReactiveUseCase {
  PortfolioUseCase(this._repository);

  final Web3Repository _repository;

  Future<String> getWalletNativeTokenBalance(String address) async {
    final wallet =
        await (await _repository.tokenContract).getEthBalance(address);
    return (wallet.getInWei.toDouble() / pow(10, 18))
        .toStringAsFixed(Config.decimalShowFixed);
  }
}
