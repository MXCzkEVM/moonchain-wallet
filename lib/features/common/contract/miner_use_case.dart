import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class MinerUseCase extends ReactiveUseCase {
  MinerUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  Future<bool> claimMinersReward({
    required List<String> selectedMinerListId,
    required Account account,
  }) async {
    return await _repository.minerRepository.claimMinersReward(
        selectedMinerListId: selectedMinerListId, account: account);
  }
}
