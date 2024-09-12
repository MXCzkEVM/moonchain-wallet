import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:f_logs/f_logs.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'account_cache_repository.dart';

class LogOutUseCase {
  LogOutUseCase({
    required this.accountCacheRepository,
    required this.authUseCase,
    required this.passcodeUseCase,
    required this.webviewUseCase,
  });

  final AccountCacheRepository accountCacheRepository;
  final AuthUseCase authUseCase;
  final PasscodeUseCase passcodeUseCase;
  final WebviewUseCase webviewUseCase;

  Future<void> logOut() async {
    FLog.clearLogs();
    accountCacheRepository.clear();
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
