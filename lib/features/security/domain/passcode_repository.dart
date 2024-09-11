import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class PasscodeRepository extends GlobalCacheRepository {
  @override
  final String zone = 'passcode';

  late final Field<String?> passcode = field('passcode');
  late final Field<int?> millisecondsLastSessionEnd =
      field('millisecondsLastSessionEnd');
  late final Field<bool> biometricEnabled =
      fieldWithDefault('biometricEnabled', false);
  late final Field<bool> needPasscodeForSession =
      fieldWithDefault('needPasscodeForSession', false);
  late final Field<bool> needSetPasscode =
      fieldWithDefault('needSetPasscode', false);

  /// Time when user did actions which caused app lock (e.g. entered passcode 3 times incorrect)
  late final Field<DateTime?> penaltyLockTime = field('penaltyLockTime');
}
