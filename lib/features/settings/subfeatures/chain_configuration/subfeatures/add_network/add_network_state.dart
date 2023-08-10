import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AddNetworkState with EquatableMixin {
  List<Network> networks = [];

  @override
  List<Object?> get props => [
        networks,
      ];
}
