import 'package:moonchain_wallet/core/core.dart';
import 'package:collection/collection.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';

final passcodeSetConfirmPageContainer = PresenterContainerWithParameter<
    PasscodeSetConfirmPagePresenter,
    PasscodeBasePageState,
    List<int>>((expectedNumbers) {
  return PasscodeSetConfirmPagePresenter(expectedNumbers);
});

enum PasscodeConfirmResult { ok, dontMatch }

class PasscodeSetConfirmPagePresenter extends PasscodeBasePagePresenter {
  PasscodeSetConfirmPagePresenter(this.expectedNumbers)
      : super(PasscodeBasePageState());

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  final List<int> expectedNumbers;

  @override
  void onAllNumbersEntered(String? dismissedPage) {
    if (!const DeepCollectionEquality()
        .equals(state.enteredNumbers, expectedNumbers)) {
      navigator?.pop(PasscodeConfirmResult.dontMatch);
      return;
    }

    _passcodeUseCase.setNeedSetPasscode(false);
    _passcodeUseCase.setPasscode(expectedNumbers.join());

    pushWalletCreationNoticePage(context!);
  }
}
