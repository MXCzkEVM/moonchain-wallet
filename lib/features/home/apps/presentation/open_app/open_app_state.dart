import 'package:equatable/equatable.dart';
import 'package:web3dart/credentials.dart';

class OpenAppState with EquatableMixin {
  EthereumAddress? address;

  @override
  List<Object?> get props => [
        address,
      ];
}
