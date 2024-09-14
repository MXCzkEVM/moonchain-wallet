import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:moonchain_wallet/common/biometric.dart';
import 'package:moonchain_wallet/core/core.dart';

import 'passcode_base_page_state.dart';

const passcodeTransitionDuration = Duration(milliseconds: 400);

abstract class PasscodeBasePagePresenter<T extends PasscodeBasePageState>
    extends CompletePresenter<T> {
  PasscodeBasePagePresenter(T defaultState) : super(defaultState);

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  @override
  void initState() {
    super.initState();

    // Simulate initial lifecycle change
    onAppLifecycleChanged(
      null,
      AppLifecycleState.resumed,
    );

    listen<bool>(
      _passcodeUseCase.biometricEnabled,
      (biometricEnabled) =>
          notify(() => state.isBiometricEnabled = biometricEnabled),
    );
  }

  void onAllNumbersEntered(String? dismissedPage);

  Future<void> onAppLifecycleChanged(
    AppLifecycleState? previous,
    AppLifecycleState current,
  ) async {
    final userHasActiveFingerprints = await Biometric.userHasFingerPrints();
    notify(() => state.userHasActiveFingerprints = userHasActiveFingerprints);
  }

  Future<bool> requestBiometrics() async {
    return await Biometric.authenticate(context!);
  }

  void onAddNumber(int number) async {
    state.enteredNumbers.add(number);
    notify();
    if (state.enteredNumbers.length != state.expectedNumbersLength) return;
    state.errorText = null;
    onAllNumbersEntered(state.dismissedPage);
  }

  void onRemoveNumber() {
    if (state.enteredNumbers.isEmpty) return;
    notify(() => state.enteredNumbers.removeLast());
  }

  void initShakeAnimationController(AnimationController animationController) {
    state.shakeAnimationController = animationController;
  }

  void startShakeAnimation() {}
}
