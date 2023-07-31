import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart'
    as network;
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class ChainConfigurationRepository extends ControlledCacheRepository {
  @override
  final String zone = 'chain_configuration';

  late final Field<List<network.Network>> networks =
      fieldWithDefault<List<network.Network>>('networks', [],
          serializer: (b) => b
              .map((e) => {
                    'logo': e.logo,
                    'web3RpcHttpUrl': e.web3RpcHttpUrl,
                    'web3RpcWebsocketUrl': e.web3RpcWebsocketUrl,
                    'web3WebSocketUrl': e.web3WebSocketUrl,
                    'symbol': e.symbol,
                    'explorerUrl': e.explorerUrl,
                    'enabled': e.enabled,
                    'label': e.label,
                    'chainId': e.chainId,
                    'gasLimit': e.gasLimit,
                    'isAdded': e.isAdded,
                    'networkType': e.networkType.name
                  })
              .toList(),
          deserializer: (b) => (b as List)
              .map((e) => network.Network(
                  logo: e['logo'],
                  web3RpcHttpUrl: e['web3RpcHttpUrl'],
                  web3RpcWebsocketUrl: e['web3RpcWebsocketUrl'],
                  web3WebSocketUrl: e['web3WebSocketUrl'],
                  symbol: e['symbol'],
                  explorerUrl: e['explorerUrl'],
                  enabled: e['enabled'],
                  label: e['label'],
                  chainId: e['chainId'],
                  gasLimit: e['gasLimit'],
                  isAdded: e['isAdded'],
                  networkType: network.NetworkType.values.firstWhere(
                      (element) => element.name == e['networkType'])))
              .toList());

  late final Field<String> selectedIpfsGateWay = fieldWithDefault<String>(
      'selectedIpfsGateWay', '',
      serializer: (b) => b, deserializer: (b) => b);

  List<network.Network> get items => networks.value;

  String get selectedIpfsGatewayItem => selectedIpfsGateWay.value;

  /// Add
  void addItem(network.Network item) =>
      networks.value = [...networks.value, item];

  void updateItem(network.Network item) {
    final itemIndex =
        networks.value.indexWhere((element) => element.chainId == item.chainId);
    if (itemIndex != -1) {
      final newList = networks.value;
      newList.removeAt(itemIndex);
      newList.insert(itemIndex, item);
      networks.value = newList;
    }
  }

  void addItems(List<network.Network> items) =>
      networks.value = [...networks.value, ...items];

  void removeItem(network.Network item) => networks.value =
      networks.value.where((e) => e.chainId != item.chainId).toList();

  void changeIpfsGateWay(String ipfsGateWay) =>
      selectedIpfsGateWay.value = ipfsGateWay;
}
