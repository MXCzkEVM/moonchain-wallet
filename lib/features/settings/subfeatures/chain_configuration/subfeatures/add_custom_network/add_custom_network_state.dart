import 'package:equatable/equatable.dart';
import '../../entities/network.dart';

class AddCustomNetworkState with EquatableMixin {
  List<Network> networks = [];
  int? chainId;
  bool ableToSave = false;

  @override
  List<Object?> get props => [networks, chainId, ableToSave];
}
