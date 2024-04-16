import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';

class IPFSUseCase extends ReactiveUseCase {
  IPFSUseCase(this._repository, this._chainConfigurationUseCase) {
    initializeIpfsGateways();
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  void initializeIpfsGateways() async {
    Utils.retryFunction(() async {
      final List<String>? list = await getIpfsGateWays();

      if (list != null) {
        checkIpfsGateways(list);
      } else {
        throw 'Error while retrieving ipfs gateway list!';
      }
    });
  }

  // Future<List<String>> loadLocalData() {
    
  // }

  Future<List<String>> getDefaultIpfsGateWays() async {
    final result = await _repository.ipfsRepository.getDefaultIpfsGateways();
    final List<String> list = [];

    if (result != null) {
      list.addAll(result.gateways ?? []);
    }

    return list;
  }

  Future<bool> checkIpfsGatewayStatus(String url) async {
    return await _repository.ipfsRepository.checkIpfsGateway(url);
  }

  Future<List<String>?> getIpfsGateWays() async {
    final newList = await getDefaultIpfsGateWays();
    _chainConfigurationUseCase.updateIpfsGateWayList(newList);

    return newList;
  }

  void checkIpfsGateways(List<String> list) async {
    for (int i = 0; i < list.length; i++) {
      final cUrl = list[i];
      final response = await checkIpfsGatewayStatus(cUrl);

      if (response != false) {
        _chainConfigurationUseCase.changeIpfsGateWay(cUrl);
        break;
      }
    }
  }
}
