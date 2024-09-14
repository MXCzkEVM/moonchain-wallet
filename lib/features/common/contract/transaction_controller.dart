import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class TransactionControllerUseCase extends ReactiveUseCase {
  TransactionControllerUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  Future<TransactionModel> cancelTransaction(
    TransactionModel toCancelTransaction,
    Account account,
    EtherAmount maxFeePerGas,
    EtherAmount priorityFee,
  ) async {
    return await _repository.transactionController.cancelTransaction(
      toCancelTransaction,
      account,
      maxFeePerGas,
      priorityFee,
    );
  }

  Future<TransactionModel> speedUpTransaction(
    TransactionModel toSpeedUpTransaction,
    Account account,
    EtherAmount maxFeePerGas,
    EtherAmount priorityFee,
  ) async {
    return await _repository.transactionController.speedUpTransaction(
      toSpeedUpTransaction,
      account,
      maxFeePerGas,
      priorityFee,
    );
  }
}
