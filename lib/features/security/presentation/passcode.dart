import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';

import 'passcode_set/passcode_set_page/passcode_set_page.dart';
import 'setup_enable_biometric/setup_enable_biometric_page.dart';

Future<void> pushPasscodeSetPage(BuildContext context) {
  return Navigator.of(context).replaceAll(
    route(
      const PasscodeSetPage(),
    ),
  );
}

Future<void> pushSetupEnableBiometricPage(BuildContext context) {
  return Navigator.of(context).replaceAll(
    route(
      const SetupEnableBiometricPage(),
    ),
  );
}
