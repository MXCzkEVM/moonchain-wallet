import 'package:equatable/equatable.dart';

class EditRecipientState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
      ];
}
