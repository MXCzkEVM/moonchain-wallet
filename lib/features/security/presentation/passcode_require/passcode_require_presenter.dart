import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:vibration/vibration.dart';

import 'passcode_require_state.dart';
import 'wrapper/passcode_require_wrapper_presenter.dart';

final passcodeRequirePageContainer =
    PresenterContainer<PasscodeRequirePresenter, PasscodeRequiredPageState>(
        () => PasscodeRequirePresenter());

class PasscodeRequirePresenter
    extends PasscodeBasePagePresenter<PasscodeRequiredPageState> {
  PasscodeRequirePresenter() : super(PasscodeRequiredPageState());

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1), () {
      if (_passcodeUseCase.biometricEnabled.value) {
        requestBiometrics();
      }
    });
  }

  @override
  void startShakeAnimation() {
    if (state.shakeAnimationController != null) {
      state.shakeAnimationController!.forward();
    }
  }

  @override
  void onAllNumbersEntered(String? dismissedPage) async {
    if (state.enteredNumbers.join('') != _passcodeUseCase.passcode.value) {
      if (state.wrongInputCounter < 5) {
        state.wrongInputCounter++;
        state.errorText = translate('attempts_x')!
            .replaceFirst('{0}', '${6 - state.wrongInputCounter}');
        vibrate();
        startShakeAnimation();
      } else {
        state.errorText = null;
        state.wrongInputCounter = 0;

        ref.read(logOutUseCaseProvider).logOut();
        navigator?.replaceAll(route(const SplashSetupWalletPage()));
      }
      state.enteredNumbers = [];
      notify();
      return;
    }

    ref.read(passcodeRequireWrapperContainer.actions).hideLockScreen();
  }

  @override
  Future<bool> requestBiometrics() async {
    final result = await super.requestBiometrics();

    if (result) {
      ref.read(passcodeRequireWrapperContainer.actions).hideLockScreen();
    } else {
      notify(() {
        state.errorText = translate('try_again')!;
        state.enteredNumbers = [];
      });
    }

    return result;
  }

  void vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 400);
    }
  }
}
