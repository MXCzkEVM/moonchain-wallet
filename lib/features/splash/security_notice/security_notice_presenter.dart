import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/presentation/passcode.dart';

import 'security_notice_state.dart';

final securityNoticeContainer = PresenterContainerWithParameter<
    SecurityNoticePresenter,
    SecurityNoticeState,
    String>((phrases) => SecurityNoticePresenter(phrases));

class SecurityNoticePresenter extends CompletePresenter<SecurityNoticeState> {
  SecurityNoticePresenter(this.phrases) : super(SecurityNoticeState());

  final String phrases;

  late final _walletUseCase = ref.read(walletUseCaseProvider);

  void confirm() {
    // _walletUseCase.setupFromMnemonic(phrases);

    if (Biometric.available) {
      pushSetupEnableBiometricPage(context!);
    } else {
      pushPasscodeSetPage(context!);
    }
  }
}
