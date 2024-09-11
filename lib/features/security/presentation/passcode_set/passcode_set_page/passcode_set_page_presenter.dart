import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';

final passcodeSetPageContainer =
    PresenterContainer<PasscodeSetPagePresenter, PasscodeBasePageState>(
  () => PasscodeSetPagePresenter(),
);

class PasscodeSetPagePresenter extends PasscodeBasePagePresenter {
  PasscodeSetPagePresenter() : super(PasscodeBasePageState());

  @override
  void onAllNumbersEntered(String? dismissedPage) async {
    Future.delayed(
      passcodeTransitionDuration,
      () => notify(() => state.enteredNumbers = []),
    );

    final res = await navigator
        ?.push(
          route.featureDialogPage(
            PasscodeSetConfirmPage(
              expectedNumbers: state.enteredNumbers,
            ),
          ),
        )
        .then((value) => value as PasscodeConfirmResult?);

    if (res == null) {
      return;
    } else if (res == PasscodeConfirmResult.dontMatch) {
      state.errorText = translate('passcode_didnt_match')!;
      notify();
    }
  }
}
