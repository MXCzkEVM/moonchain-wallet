import 'package:equatable/equatable.dart';

class RecoveryPhraseBaseState with EquatableMixin {
  bool acceptAgreement = false;

  @override
  List<Object?> get props => [
        acceptAgreement,
      ];
}
