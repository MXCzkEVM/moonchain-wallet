import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';

import 'chain_configuration_repository.dart';

class ChainConfigurationUseCase extends ReactiveUseCase {
  ChainConfigurationUseCase(this._repository);

  final ChainConfigurationRepository _repository;

  late final ValueStream<List<Network>> networks =
      reactiveField(_repository.networks);

  late final ValueStream<String> selectedIpfsGateWay =
      reactiveField(_repository.selectedIpfsGateWay);

  List<Network> getNetworks() => _repository.items;

  String getIpfsGateWay() => _repository.selectedIpfsGatewayItem;

  void addItem(Network network) {
    _repository.addItem(network);
    update(networks, _repository.items);
  }

  void updateItem(Network network) {
    _repository.addItem(network);
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
}
