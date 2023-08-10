import 'package:equatable/equatable.dart';

class PasscodeBasePageState with EquatableMixin {
  final int expectedNumbersLength = 6;
  List<int> enteredNumbers = [];
  String? errorText;
  bool isBiometricEnabled = false;
  bool userHasActiveFingerprints = false;

  String? dismissedPage;

  @override
  List<Object?> get props => [
        expectedNumbersLength,
        enteredNumbers,
        errorText,
        isBiometricEnabled,
        userHasActiveFingerprints,
      ];
}
