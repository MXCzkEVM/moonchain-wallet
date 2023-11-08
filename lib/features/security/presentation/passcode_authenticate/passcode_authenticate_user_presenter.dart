import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'passcode_authenticate_user_state.dart';

final passcodeAuthenticateUserContainer = PresenterContainer<
    PasscodeAuthenticateUserPresenter,
    PasscodeAuthenticateUserState>(() => PasscodeAuthenticateUserPresenter());

class PasscodeAuthenticateUserPresenter
    extends PasscodeBasePagePresenter<PasscodeAuthenticateUserState> {
  PasscodeAuthenticateUserPresenter() : super(PasscodeAuthenticateUserState());

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  @override
  void onAllNumbersEntered(String? dismissedPage) async {
    if (state.enteredNumbers.join('') != _passcodeUseCase.passcode.value) {
      if (state.wrongInputCounter < 2) {
        state.errorText = translate('incorrect_passcode')!;
        state.wrongInputCounter++;
      } else {
        state.errorText = null;
        state.wrongInputCounter = 0;
        ref.read(passcodeUseCaseProvider).penaltyLock();
      }
      state.enteredNumbers = [];
      notify();
      return;
    }

    Future.delayed(
      passcodeTransitionDuration,
      () => notify(() => state.enteredNumbers = []),
    );

    navigator?.pop(true);
  }
}
