import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AddNFTState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
      ];
}
