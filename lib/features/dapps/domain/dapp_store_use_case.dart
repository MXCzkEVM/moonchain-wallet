import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DappStoreUseCase extends ReactiveUseCase {
  DappStoreUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  late final ValueStream<List<Dapp>> dapps = reactive([]);

  Future<void> getAllDapps() async {
    final result = await _repository.dappStoreRepository.getAllDapps();

    update(dapps, result);
  }
}
