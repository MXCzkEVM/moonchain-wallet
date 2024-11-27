import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:local_auth/local_auth.dart';

class Biometric {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static List<BiometricType>? _availableBiometrics;
  static List<BiometricType> get availableBiometrics =>
      _availableBiometrics ?? [];

  static bool get available => availableBiometrics.isNotEmpty;

  // iOS only
  static BiometricType? _iosSystemBiometric;
  static BiometricType? get iosSystemBiometric => _iosSystemBiometric;

  static Future<void> load() async {
    try {
      _availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (_availableBiometrics?.contains(BiometricType.face) ?? false) {
          _iosSystemBiometric = BiometricType.face;
        } else if (_availableBiometrics?.contains(BiometricType.fingerprint) ??
            false) {
          _iosSystemBiometric = BiometricType.face;
        } else {
          log('No biometrics are available on this iOS device!');
          _availableBiometrics = [];
        }
      }
    } catch (e, s) {
      log('Can\'t load biometric', error: e, stackTrace: s);
      _availableBiometrics = [];
    }
  }

  static Future<bool> authenticate(BuildContext context) async {
    try {
      final localizedReason = FlutterI18n.translate(context, 'verify');

      if (!await _localAuth.isDeviceSupported()) return false;

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
