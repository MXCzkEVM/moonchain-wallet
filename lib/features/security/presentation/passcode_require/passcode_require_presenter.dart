import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';

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
  void onAllNumbersEntered() async {
    if (state.enteredNumbers.join('') != _passcodeUseCase.passcode.value) {
      if (state.wrongInputCounter < 2) {
        state.errorText = translate('incorrect_passcode')!;
        state.wrongInputCounter++;
      } else {
        state.errorText = null;
        state.wrongInputCounter = 0;
        ref.read(passcodeUseCaseProvider).penaltyLock();
        _passcodeUseCase.setPasscodeScreenIsShown(true);
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
}
