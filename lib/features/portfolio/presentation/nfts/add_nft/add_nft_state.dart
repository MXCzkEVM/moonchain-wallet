import 'package:equatable/equatable.dart';

class AddNFTState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
      ];
}
