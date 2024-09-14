import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moonchain_wallet/common/biometric.dart';

String biometricSystemName(BuildContext context) {
  if (Platform.isAndroid) {
    return FlutterI18n.translate(context, 'biometrics');
  }
  if (Biometric.iosSystemBiometric == BiometricType.face) {
    return 'Face ID';
  } else if (Biometric.iosSystemBiometric == BiometricType.fingerprint) {
    return 'Touch ID';
  } else {
    return FlutterI18n.translate(context, 'biometrics');
  }
}
