import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'chain_configuration_repository.dart';

class ChainConfigurationUseCase extends ReactiveUseCase {
  ChainConfigurationUseCase(
    this._repository,
  );

  final ChainConfigurationRepository _repository;

  late final ValueStream<List<Network>> networks =
      reactiveField(_repository.networks);

  late final ValueStream<String?> selectedIpfsGateWay =
      reactiveField(_repository.selectedIpfsGateWay);

  late final ValueStream<List<String>> ipfsGateWayList = reactive([]);

  late final ValueStream<Network?> selectedNetwork = reactive();

  late final ValueStream<Network?> selectedNetworkForDetails = reactive();

  List<Network> getNetworks() => _repository.items;

  String? getIpfsGateWay() => _repository.selectedIpfsGatewayItem;

  void addItem(Network network) {
    _repository.addItem(network);
    update(networks, _repository.items);
  }

  void updateItem(Network network, int index) {
    _repository.updateItem(network, index);
    update(networks, _repository.items);
  }

  void addItems(List<Network> items) {
    _repository.addItems(items);
    update(networks, _repository.items);
  }

  void removeItem(Network network) {
    _repository.removeItem(network);
    update(networks, _repository.items);
  }

  void changeIpfsGateWay(String newIpfsGateWay) {
    _repository.changeIpfsGateWay(newIpfsGateWay);
    update(selectedIpfsGateWay, _repository.selectedIpfsGatewayItem);
  }

  void updateIpfsGateWayList(List<String> newIpfsGateWayList) {
    update(ipfsGateWayList, newIpfsGateWayList);
  }

  void switchDefaultNetwork(Network newDefault) {
    final currentDefaultItemIndex =
        networks.value.indexWhere((element) => element.enabled == true);
    final newDefaultItemIndex = networks.value
        .indexWhere((element) => element.chainId == newDefault.chainId);

    if (currentDefaultItemIndex != -1 &&
        newDefaultItemIndex != -1 &&
        currentDefaultItemIndex != newDefaultItemIndex) {
      final currentDefault =
          networks.value[currentDefaultItemIndex].copyWith(enabled: false);
      newDefault = newDefault.copyWith(enabled: true, isAdded: true);

      updateItem(newDefault, newDefaultItemIndex);
      updateItem(currentDefault, currentDefaultItemIndex);

      update(selectedNetwork, newDefault);
    }
  }

  void getCurrentNetwork() {
    final currentNetwork =
        _repository.items.where((item) => item.enabled).first;
    update(selectedNetwork, currentNetwork);
  }

  Network getCurrentNetworkWithoutRefresh() {
    return 
        _repository.items.where((item) => item.enabled).first;
  }

  void refresh() {
    update(networks, networks.value);
    update(selectedNetwork, selectedNetwork.value);
  }

  /// only for details of custom network delete network page
  void selectNetworkForDetails(Network network) {
    update(selectedNetworkForDetails, network);
  }
}
