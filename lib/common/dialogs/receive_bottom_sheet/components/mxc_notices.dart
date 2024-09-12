import 'package:mxc_logic/mxc_logic.dart';
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

  final thirdSplit = secondSplit[1].split('{2}');
  final thirdPart = secondSplit[0];

  final fourthSplit = thirdSplit[1].split('{3}');
  final fourthPart = fourthSplit[0];

  final fifthSplit = fourthSplit[1].split('{4}');
  final fifthPart = fifthSplit[0];

  final sixthSplit = fifthSplit[1].split('{5}');
  final sixthPart = sixthSplit[0];

  final seventhSplit = sixthSplit[1].split('{6}');
  final seventhPart = seventhSplit[0];

  final eighthPart = seventhSplit[1];
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
    TextSpan(
      text: 'KuCoin',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.kucoin);
        },
    ),
    TextSpan(text: fourthPart),
    TextSpan(
      text: 'Crypto.com',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.cryptocom);
        },
    ),
    TextSpan(text: fifthPart),
    TextSpan(
      text: 'Bitget',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.bitget);
        },
    ),
    TextSpan(text: sixthPart),
    TextSpan(
      text: 'HTX',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.htx);
        },
    ),
    TextSpan(text: seventhPart),
    TextSpan(
      text: 'BitMart',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.bitmart);
        },
    ),
    TextSpan(text: eighthPart),
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
