import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';

final setupEnableBiometricContainer =
    PresenterContainer<SetupEnableBiometricPresenter, void>(
        () => SetupEnableBiometricPresenter());

class SetupEnableBiometricPresenter extends CompletePresenter<void> {
  SetupEnableBiometricPresenter() : super(null);

  String getAppBarTitle() => (Platform.isAndroid)
      ? 'biometrics'
      : Biometric.iosSystemBiometric == BiometricType.face
          ? 'face_id'
          : 'touch_id';

  String getSvg() => (Platform.isAndroid)
      ? 'assets/svg/ic_face_touch_id.svg'
      : Biometric.iosSystemBiometric == BiometricType.face
          ? 'assets/svg/ic_biometric.svg'
          : 'assets/svg/ic_touch_id.svg';

  String getDesc() => 'enable_${getAppBarTitle()}_desc';

  void authenticateBiometrics() async {
    final res = await Biometric.authenticate(context!);
    if (res) {
      ref.read(passcodeUseCaseProvider).setBiometricEnabled(true);
      // _finishPasscodeSetup();
    }
  }

  // void skip() => _finishPasscodeSetup();

  // void _finishPasscodeSetup() {
  //   finishPasscodeSetup(navigator!);
  // }
}
