import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';

import 'passcode_change_enter_current_page_state.dart';

final passcodeChangeEnterCurrentPageContainer = PresenterContainer<
        PasscodeChangeEnterCurrentPagePresenter,
        PasscodeChangeEnterCurrentPageState>(
    () => PasscodeChangeEnterCurrentPagePresenter());

class PasscodeChangeEnterCurrentPagePresenter
    extends PasscodeBasePagePresenter<PasscodeChangeEnterCurrentPageState> {
  PasscodeChangeEnterCurrentPagePresenter()
      : super(PasscodeChangeEnterCurrentPageState());

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

    final res = await navigator
        ?.push(route.featureDialogPage(
            PasscodeChangeEnterNewPage(dismissedDest: dismissedPage)))
        .then((v) => v as String?);

    if (res == null) {
      return;
    }
  }
}
