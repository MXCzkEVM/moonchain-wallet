import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

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
