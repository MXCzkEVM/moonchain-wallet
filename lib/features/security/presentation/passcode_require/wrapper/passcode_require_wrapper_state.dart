import 'package:equatable/equatable.dart';

class PasscodeRequireWrapperState with EquatableMixin {
  bool showPasscode = false;

  @override
  List<Object?> get props => [showPasscode];
}
