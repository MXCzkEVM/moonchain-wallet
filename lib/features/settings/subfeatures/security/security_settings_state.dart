import 'package:equatable/equatable.dart';

class SecuritySettingsState with EquatableMixin {
  bool biometricEnabled = false;

  @override
  List<Object?> get props => [
        biometricEnabled,
      ];
}
