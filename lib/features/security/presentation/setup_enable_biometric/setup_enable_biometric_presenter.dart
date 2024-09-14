import 'dart:io';

import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/splash/mns_process/mns.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';

final setupEnableBiometricContainer =
    PresenterContainer<SetupEnableBiometricPresenter, void>(
        () => SetupEnableBiometricPresenter());

class SetupEnableBiometricPresenter extends CompletePresenter<void> {
  SetupEnableBiometricPresenter() : super(null);

  String getAppBarTitle() => (Platform.isAndroid)
      ? 'fingerprint'
      : Biometric.iosSystemBiometric == BiometricType.face
          ? 'face_id'
          : 'touch_id';

  String getSvg() => (Platform.isAndroid)
      ? 'assets/svg/security/ic_fingerprint.svg'
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
