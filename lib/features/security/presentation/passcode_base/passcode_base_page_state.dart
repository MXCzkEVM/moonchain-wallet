import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PasscodeBasePageState with EquatableMixin {
  final int expectedNumbersLength = 6;
  List<int> enteredNumbers = [];
  String? errorText;
  bool isBiometricEnabled = false;
  bool userHasActiveFingerprints = false;
  AnimationController? shakeAnimationController;

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
