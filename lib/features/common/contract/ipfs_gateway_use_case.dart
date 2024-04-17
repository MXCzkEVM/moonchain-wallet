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
    processIpfsGatewayListLocal();
    Utils.retryFunction(processIpfsGatewayList);
  }

  Future<void> processIpfsGatewayListLocal() async =>
      checkIpfsGatewaysWrapper(getIpfsGateWaysLocal);

  Future<void> processIpfsGatewayList() async =>
      checkIpfsGatewaysWrapper(getIpfsGateWays);

  Future<List<String>> getDefaultIpfsGateWaysLocal() async =>
      getDefaultIpfsGateWaysWrapper(
          _repository.ipfsRepository.getDefaultIpfsGatewaysFromLocal);

  Future<List<String>> getDefaultIpfsGateWays() async =>
      getDefaultIpfsGateWaysWrapper(
          _repository.ipfsRepository.getDefaultIpfsGateways);

  Future<List<String>> getDefaultIpfsGateWaysWrapper(
      Future<DefaultIpfsGateways> Function() function) async {
    final result = await function();
    final List<String> list = [];

    list.addAll(result.gateways ?? []);

    return list;
  }

  Future<bool> checkIpfsGatewayStatus(String url) async {
    return await _repository.ipfsRepository.checkIpfsGateway(url);
  }

  Future<List<String>?> getIpfsGateWaysLocal() async {
    final newList = await getDefaultIpfsGateWaysLocal();
    _chainConfigurationUseCase.updateIpfsGateWayList(newList);

    return newList;
  }

  Future<List<String>?> getIpfsGateWays() async {
    final newList = await getDefaultIpfsGateWays();
    _chainConfigurationUseCase.updateIpfsGateWayList(newList);

    return newList;
  }

  void checkIpfsGatewaysWrapper(
      Future<List<String>?> Function() function) async {
    final List<String>? list = await function();

    if (list != null) {
      checkIpfsGateways(list);
    } else {
      throw 'Error while retrieving ipfs gateway list!';
    }
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
