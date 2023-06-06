import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:local_auth/local_auth.dart';

class Biometric {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static List<BiometricType>? _availableBiometrics;
  static List<BiometricType> get availableBiometrics => _availableBiometrics ?? [];

  static bool get available => availableBiometrics.isNotEmpty;

  // iOS only
  static BiometricType? _iosSystemBiometric;
  static BiometricType? get iosSystemBiometric => _iosSystemBiometric;

  static Future<void> load() async {
    try {
      _availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (Platform.isIOS) {
        _iosSystemBiometric = await _localAuth.getIosBiometricType();
      }
    } catch (e, s) {
      log('Can\'t load biometric', error: e, stackTrace: s);
      _availableBiometrics = [];
    }
  }

  // Android only
  static Future<bool> userHasFingerPrints() async {
    if (Platform.isAndroid) {
      return await _localAuth.userHasActiveFingerprints();
    } else {
      return true;
    }
  }

  static Future<bool> authenticate(BuildContext context) async {
    try {
      final localizedReason = FlutterI18n.translate(context, 'verify');

      if (!await _localAuth.isDeviceSupported()) return false;

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        useErrorDialogs: true,
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}
