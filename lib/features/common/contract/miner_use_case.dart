import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

class MinerUseCase extends ReactiveUseCase {
  MinerUseCase(this._repository, this._contextLessTranslationUseCase);

  final Web3Repository _repository;
  final ContextLessTranslationUseCase _contextLessTranslationUseCase;

  // Context less translation, This should be only used for BG functions
  String cTranslate(String key) =>
      _contextLessTranslationUseCase.translate(key);

  Future<bool> claimMinersReward({
    required List<String> selectedMinerListId,
    required Account account,
    required void Function(
      String title,
      String? text,
    )
        showNotification,
    required String Function(
      String key,
    )
        translate,
  }) async {
    return await _repository.minerRepository.claimMinersReward(
        selectedMinerListId: selectedMinerListId,
        account: account,
        showNotification: showNotification,
        translate: translate);
  }

  Future<MinerListModel> getAddressMiners(
    String address,
  ) async =>
      await _repository.minerRepository.getAddressMiners(address);

  Future<List<ClaimEarn>> helperGetClaimRewards(
    GetClaimRewardsQuery query,
  ) async {
    return await _repository.minerRepository.helperGetClaimRewards(query);
  }

  Future<GetTotalClaimResponse> helperGetClaimTotal(
    GetClaimTotalQuery query,
    String address,
    List<String> miners,
  ) async {
    return await _repository.minerRepository
        .helperGetClaimTotal(query, address, miners);
  }

  void getExpirationDateForEpoch() async {
    return _repository.minerRepository.getExpirationDurationForEpoch();
  }
}
