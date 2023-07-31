import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';

import '../widgets/add_network_item.dart';

class AddNetworkUtils {
  static List<Widget> generateMainnetList(List<Network> networkList) {
    return networkList
        .where((element) => element.networkType == NetworkType.mainnet)
        .map((e) => AddNetworkItem(network: e))
        .toList();
  }

  static List<Widget> generateTestnetList(List<Network> networkList) {
    return networkList
        .where((element) => element.networkType == NetworkType.testnet)
        .map((e) => AddNetworkItem(network: e))
        .toList();
  }
}
