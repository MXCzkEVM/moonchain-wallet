import 'package:collection/collection.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';

final passcodeChangeConfirmPageContainer = PresenterContainerWithParameter<
    PasscodeChangeConfirmPagePresenter,
    PasscodeBasePageState,
    List<int>>((expectedNumbers) {
  return PasscodeChangeConfirmPagePresenter(expectedNumbers);
});

enum PasscodeChangeConfirmResult { dontMatch }

class PasscodeChangeConfirmPagePresenter extends PasscodeBasePagePresenter {
  PasscodeChangeConfirmPagePresenter(this.expectedNumbers)
      : super(PasscodeBasePageState());

  final List<int> expectedNumbers;

  late final PasscodeUseCase _passcodeUseCase =
      ref.read(passcodeUseCaseProvider);

  @override
  void onAllNumbersEntered(String? dismissedPage) {
    if (!const DeepCollectionEquality()
        .equals(state.enteredNumbers, expectedNumbers)) {
      navigator?.pop(PasscodeChangeConfirmResult.dontMatch);
      return;
    }

    _passcodeUseCase.setNeedSetPasscode(false);
    _passcodeUseCase.setPasscode(expectedNumbers.join());

    navigator?.popUntil((route) {
      return route.settings.name?.contains('SecuritySettingsPage') ?? false;
    });
  }
}
