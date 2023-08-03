import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DeleteCustomNetworkState with EquatableMixin {
  List<Network> networks = [];
  int? chainId;
  bool ableToSave = true;

  bool isEnabled = false;

  @override
  List<Object?> get props => [networks, chainId, ableToSave, isEnabled];
}
