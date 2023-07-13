import 'package:equatable/equatable.dart';

class AddRecipientState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
      ];
}
