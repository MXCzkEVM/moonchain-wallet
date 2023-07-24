import 'package:equatable/equatable.dart';

class AddNftState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
      ];
}
