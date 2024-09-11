import 'package:moonchain_wallet/core/core.dart';

import 'passcode_repository.dart';

class PasscodeUseCase extends ReactiveUseCase {
  PasscodeUseCase(this._repository);

  final PasscodeRepository _repository;
  late final ValueStream<String?> passcode =
      reactiveField(_repository.passcode);

  late final ValueStream<DateTime?> penaltyLockTime =
      reactiveField(_repository.penaltyLockTime);

  late final ValueStream<bool> passcodeScreenIsShown = reactive(false);

  ValueStream<DateTime?> get penaltyUnlockTime => penaltyLockTime
      .map((e) => e?.add(penaltyDuration))
      .shareValueSeeded(penaltyLockTime.value?.add(penaltyDuration));

  Duration get penaltyDuration => const Duration(minutes: 30);

  void setPasscode(String? val) {
    update(passcode, val);
  }

  late final ValueStream<int?> millisecondsLastSessionEnd =
      reactiveField(_repository.millisecondsLastSessionEnd);

  void setMillisecondsLastSessionEnd(int? val) {
    update(millisecondsLastSessionEnd, val);
  }

  late final ValueStream<bool> biometricEnabled =
      reactiveField(_repository.biometricEnabled);

  void setBiometricEnabled(bool val) {
    update(biometricEnabled, val);
  }

  late final ValueStream<bool> needPasscodeForSession =
      reactiveField(_repository.needPasscodeForSession);

  void setNeedPasscodeForSession(bool val) {
    update(needPasscodeForSession, val);
  }

  late final ValueStream<bool> needSetPasscode =
      reactiveField(_repository.needSetPasscode);

  void setNeedSetPasscode(bool val) {
    update(needSetPasscode, val);
  }

  void penaltyLock() {
    update(penaltyLockTime, DateTime.now());
  }

  void setPenaltyLock(DateTime? dateTime) {
    update(penaltyLockTime, dateTime);
  }

  void setPasscodeScreenIsShown(bool val) {
    update(passcodeScreenIsShown, val);
  }
}
