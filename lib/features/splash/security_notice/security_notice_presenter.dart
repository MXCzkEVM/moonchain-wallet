import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/presentation/passcode.dart';

import 'security_notice_state.dart';

final securityNoticeContainer =
    PresenterContainer<SecurityNoticePresenter, SecurityNoticeState>(
        () => SecurityNoticePresenter());

class SecurityNoticePresenter extends CompletePresenter<SecurityNoticeState> {
  SecurityNoticePresenter() : super(SecurityNoticeState());

  void confirm() async {
    if (Biometric.available) {
      pushSetupEnableBiometricPage(context!);
    } else {
      pushPasscodeSetPage(context!);
    }
  }
}
