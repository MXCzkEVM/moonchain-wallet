import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class UIConfig {
  static MXCWalletButtonEdgeType get splashScreensButtonsEdgeType =>
      MXCWalletButtonEdgeType.hard;
  static MXCWalletButtonEdgeType get securityScreensButtonsEdgeType =>
      MXCWalletButtonEdgeType.hard;
  static MXCWalletButtonEdgeType get settingsScreensButtonsEdgeType =>
      MXCWalletButtonEdgeType.hard;
  static LinearGradient gradientBackground(BuildContext context) =>
      LinearGradient(
        colors: [
          ColorsTheme.of(context).darkBlue,
          ColorsTheme.of(context).charcoalGray,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Radius defaultRadius = const Radius.circular(10);
  static BorderRadiusGeometry defaultBorderRadiusAll = BorderRadius.all(defaultRadius);
}
