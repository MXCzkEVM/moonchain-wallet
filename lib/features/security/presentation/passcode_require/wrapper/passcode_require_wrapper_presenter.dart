import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/widgets.dart';
import 'package:moonchain_wallet/core/core.dart';

import 'passcode_require_wrapper_state.dart';

final passcodeRequireWrapperContainer = PresenterContainer<
    PasscodeRequireWrapperPresenter,
    PasscodeRequireWrapperState>(() => PasscodeRequireWrapperPresenter());

class PasscodeRequireWrapperPresenter
    extends CompletePresenter<PasscodeRequireWrapperState> {
  PasscodeRequireWrapperPresenter() : super(PasscodeRequireWrapperState());

  static const int minutesForUserSession = 2;

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  late final _authUseCase = ref.read(authUseCaseProvider);

  @override
  Future<void> initState() async {
    super.initState();

    if (!_passcodeUseCase.biometricEnabled.value &&
        _passcodeUseCase.passcode.value == null) {
      await Future.delayed(const Duration(milliseconds: 1));
      pushSetupEnableBiometricPage(context!);
      return;
    }

    // Simulate initial lifecycle change
    onAppLifecycleChanged(
      null,
      AppLifecycleState.resumed,
    );

    _passcodeUseCase.setPasscodeScreenIsShown(true);

    if (_authUseCase.loggedIn &&
        _passcodeUseCase.passcode.value != null &&
        !isUnderPenalty) {
      showLockScreen();
    }
  }

  bool get isUnderPenalty =>
      _passcodeUseCase.penaltyUnlockTime.valueOrNull != null &&
      _passcodeUseCase.penaltyUnlockTime.value!.isAfter(DateTime.now());

  Future<void> onAppLifecycleChanged(
    AppLifecycleState? previous,
    AppLifecycleState current,
  ) async {
    if (_authUseCase.loggedIn) {
      DateTime? dateTimeLastSessionEnd;
      if (_passcodeUseCase.millisecondsLastSessionEnd.value != null) {
        dateTimeLastSessionEnd = DateTime.fromMillisecondsSinceEpoch(
            _passcodeUseCase.millisecondsLastSessionEnd.value!);
      }

      final needPasscodeForSession =
          _passcodeUseCase.needPasscodeForSession.value;

      if (previous == AppLifecycleState.resumed &&
          current != AppLifecycleState.resumed &&
          !needPasscodeForSession) {
        // User closed the app
        _passcodeUseCase.setMillisecondsLastSessionEnd(
          DateTime.now().millisecondsSinceEpoch,
        );
      } else if (dateTimeLastSessionEnd != null &&
          current == AppLifecycleState.resumed) {
        // User opened the app
        if (DateTime.now().difference(dateTimeLastSessionEnd).inMinutes >=
                minutesForUserSession &&
            _passcodeUseCase.passcode.value != null) {
          _passcodeUseCase.setNeedPasscodeForSession(true);
          if (!state.showPasscode && !isUnderPenalty) {
            showLockScreen();
          }
        }
      }
    }
  }

  void showLockScreen() async {
    _passcodeUseCase.setNeedPasscodeForSession(false);
    _passcodeUseCase.setMillisecondsLastSessionEnd(null);

    if (!state.showPasscode) {
      notify(() => state.showPasscode = true);
      _passcodeUseCase.setPasscodeScreenIsShown(true);

      await Future.delayed(const Duration(milliseconds: 0));
      Navigator.of(context!, rootNavigator: true).push(
        route.featureDialog(const PasscodeRequirePage(), canPopThisPage: false),
      );
    }
  }

  void hideLockScreen() async {
    if (Navigator.of(context!).canPop()) {
      Navigator.of(context!).pop();
    }

    notify(() => state.showPasscode = false);
    _passcodeUseCase.setPasscodeScreenIsShown(false);
  }
}
