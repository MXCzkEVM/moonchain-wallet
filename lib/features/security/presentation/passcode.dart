import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'passcode_set/passcode_set_page/passcode_set_page.dart';

Future<void> pushPasscodeSetPage(BuildContext context) {
  return Navigator.of(context).pushReplacement(
    route(
      const PasscodeSetPage(),
    ),
  );
}