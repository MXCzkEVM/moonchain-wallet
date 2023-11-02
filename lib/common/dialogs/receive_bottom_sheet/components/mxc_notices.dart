import 'package:datadashwallet/common/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

List<TextSpan> depositFromExchangesNotice(
    BuildContext context, void Function(String) launchUrl) {
  final text = FlutterI18n.translate(context, 'deposit_from_exchanges_notice');
  final firstSplit = text.split('{0}');
  final firstPart = firstSplit[0];
  final secondSplit = firstSplit[1].split('{1}');
  final secondPart = secondSplit[0];
  final thirdPart = secondSplit[1];
  return [
    TextSpan(
      text: firstPart,
    ),
    TextSpan(
      text: 'OKX',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.okx);
        },
    ),
    TextSpan(text: secondPart),
    TextSpan(
      text: 'Gate.io',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.gateio);
        },
    ),
    TextSpan(text: thirdPart),
  ];
}

List<TextSpan> depositWithL3BridgeNotice(
  BuildContext context,
  VoidCallback onL3Tap,
) {
  final text = FlutterI18n.translate(context, 'deposit_with_l3_bridge_notice');
  final firstSplit = text.split('{0}');
  final firstPart = firstSplit[0];
  final secondPart = firstSplit[1];
  return [
    TextSpan(
      text: firstPart,
    ),
    TextSpan(
      text: 'L3 bridge',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onL3Tap,
    ),
    TextSpan(text: secondPart),
  ];
}
