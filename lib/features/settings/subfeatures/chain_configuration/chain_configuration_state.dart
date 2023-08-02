import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

import 'entities/network.dart';

class ChainConfigurationState with EquatableMixin {
  List<Network> networks = [];

  // The one that is selected is always up
  List<String>? ipfsGateWays;

  String? selectedIpfsGateWay;

  @override
  List<Object?> get props => [
        networks,
        ipfsGateWays,
        selectedIpfsGateWay,
      ];
}
