import 'package:equatable/equatable.dart';

class EditRecipientState with EquatableMixin {
  bool valid = false;
  String? errorText;

  @override
  List<Object?> get props => [valid, errorText];
}
