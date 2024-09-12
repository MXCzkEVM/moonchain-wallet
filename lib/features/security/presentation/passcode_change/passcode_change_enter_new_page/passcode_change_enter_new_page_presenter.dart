import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';

final passcodeChangeEnterNewPageContainer = PresenterContainer<
    PasscodeChangeEnterNewPagePresenter,
    PasscodeBasePageState>(() => PasscodeChangeEnterNewPagePresenter());

class PasscodeChangeEnterNewPagePresenter extends PasscodeBasePagePresenter {
  PasscodeChangeEnterNewPagePresenter() : super(PasscodeBasePageState());

  @override
  void onAllNumbersEntered(String? dismissedPage) async {
    Future.delayed(
      passcodeTransitionDuration,
      () => notify(() => state.enteredNumbers = []),
    );

    final res = await navigator
        ?.push(
          route.featureDialogPage(PasscodeChangeConfirmPage(
            expectedNumbers: state.enteredNumbers,
          )),
        )
        .then((value) => value as PasscodeChangeConfirmResult?);

    if (res == null) {
      return;
    } else if (res == PasscodeChangeConfirmResult.dontMatch) {
      state.errorText = translate('passcode_didnt_match')!;
      notify();
    }
  }
}
