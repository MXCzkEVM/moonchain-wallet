import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class ChainConfigurationRepository extends ControlledCacheRepository {
  @override
  final String zone = 'chain_configuration';

  late final Field<List<Network>> networks =
      fieldWithDefault<List<Network>>('networks', [],
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
                  })
              .toList(),
          deserializer: (b) => (b as List)
              .map((e) => Network(
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
                  ))
              .toList());

  late final Field<String> selectedIpfsGateWay = fieldWithDefault<String>(
      'selectedIpfsGateWay', '',
      serializer: (b) => b, deserializer: (b) => b);

  List<Network> get items => networks.value;

  String get selectedIpfsGatewayItem => selectedIpfsGateWay.value;

  /// Add
  void addItem(Network item) => networks.value = [...networks.value, item];

  void updateItem(Network item) {
    final itemIndex =
        networks.value.indexWhere((element) => element.chainId == item.chainId);
    if (itemIndex != -1) {
      final newList = networks.value;
      newList.removeAt(itemIndex);
      newList.insert(itemIndex, item);
      networks.value = newList;
    }
  }

  void addItems(List<Network> items) =>
      networks.value = [...networks.value, ...items];

  void removeItem(Network item) => networks.value =
      networks.value.where((e) => e.chainId != item.chainId).toList();

  void changeIpfsGateWay(String ipfsGateWay) =>
      selectedIpfsGateWay.value = ipfsGateWay;
}
