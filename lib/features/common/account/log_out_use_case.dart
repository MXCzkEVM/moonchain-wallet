import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:f_logs/f_logs.dart';
import 'package:mxc_logic/mxc_logic.dart';

class LogOutUseCase {
  LogOutUseCase({
    required this.authUseCase,
    required this.passcodeUseCase,
    required this.webviewUseCase,
  });

  final AuthUseCase authUseCase;
  final PasscodeUseCase passcodeUseCase;
  final WebviewUseCase webviewUseCase;

  Future<void> logOut() async {
    FLog.clearLogs();
    authUseCase.resetWallet();
    webviewUseCase.clearCache();

    resetProviders();
    resetPasscode();
  }

  void resetPasscode() {
    passcodeUseCase.setPasscode(null);
    passcodeUseCase.setMillisecondsLastSessionEnd(null);
    passcodeUseCase.setBiometricEnabled(false);
    passcodeUseCase.setNeedPasscodeForSession(false);
    passcodeUseCase.setPenaltyLock(null);
  }
}
