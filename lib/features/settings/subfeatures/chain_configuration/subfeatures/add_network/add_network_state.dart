import 'package:equatable/equatable.dart';
import '../../entities/network.dart';

class AddNetworkState with EquatableMixin {
  List<Network> networks = [];

  @override
  List<Object?> get props => [
        networks,
      ];
}
