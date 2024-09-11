import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DappStoreUseCase extends ReactiveUseCase {
  DappStoreUseCase(
    this._repository,
  ) {
    loadLocalDApps();
  }

  final Web3Repository _repository;

  late final ValueStream<List<Dapp>> dapps = reactive([]);

  Future<void> loadDapps() async {
    Future.delayed(
      const Duration(seconds: 1),
      () => loadLocalDApps(),
    );

    await loadRemoteDApps();
  }

  Future<void> loadLocalDApps() async {
    final result = await _repository.dappStoreRepository.getAllDappsFromLocal();
    update(dapps, result);
  }

  Future<void> loadRemoteDApps() async {
    final result = await _repository.dappStoreRepository.getAllDapps();

    update(dapps, result);
  }
}
