import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/presentation/passcode.dart';

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
