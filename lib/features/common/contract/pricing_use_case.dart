import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class PricingUseCase extends ReactiveUseCase {
  PricingUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  Future<double> getAmountsInXsd(
      double amount, Token token0, Token token1) async {
    return await _repository.pricingRepository
        .getAmountsOut(amount, token0, token1);
  }
}
