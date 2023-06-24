import 'dart:io';

import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/splash/ens_process/ens.dart';
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
      ? 'assets/svg/security/ic_face_touch_id.svg'
      : Biometric.iosSystemBiometric == BiometricType.face
          ? 'assets/svg/security/ic_biometric.svg'
          : 'assets/svg/security/ic_touch_id.svg';

  String getDesc() => 'enable_${getAppBarTitle()}_desc';

  void authenticateBiometrics() async {
    final res = await Biometric.authenticate(context!);
    ref.read(passcodeUseCaseProvider).setBiometricEnabled(res);
    _finishBiometricSetup();
  }

  void createPasscode() => _finishBiometricSetup();

  void _finishBiometricSetup() => pushPasscodeSetPage(context!);
}
