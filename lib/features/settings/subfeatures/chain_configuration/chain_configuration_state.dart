import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

import 'entities/network.dart';

class ChainConfigurationState with EquatableMixin {
  List<Network> networks = [];

  // The one that is selected is always up
  List<String> ipfsGateWays = [
    "https://ipfs.thirdwebstorage.com/ipfs/",
    "https://ipfs.w3s.link",
    "https://gateway.ipfscdn.io/ipfs/",
    "https://cloudflare-ipfs.com/ipfs/",
    "https://ipfs.io/ipfs/",
    "https://aqua-adverse-coyote-886.mypinata.cloud/ipfs/",
  ];

  String? selectedIpfsGateWay;

  Network? selectedNetwork;

  @override
  List<Object?> get props =>
      [networks, ipfsGateWays, selectedIpfsGateWay, selectedNetwork];
}
