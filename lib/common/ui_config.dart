import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class UIConfig {
  static MXCWalletButtonEdgeType get splashScreensButtonsEdgeType =>
      MXCWalletButtonEdgeType.hard;
  static MXCWalletButtonEdgeType get securityScreensButtonsEdgeType =>
      MXCWalletButtonEdgeType.hard;
  static LinearGradient get gradientBackground => const LinearGradient(
        colors: [
          Color(0xFF0E1629),
          Color(0xFF333333),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
