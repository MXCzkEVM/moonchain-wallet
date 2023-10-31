import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

List<TextSpan> buySomeXForFeeNotice(
    BuildContext context, String networkSymbol) {
  String text = FlutterI18n.translate(context, 'buy_some_x_for_fee_notice');
  text = text.replaceFirst('{0}', networkSymbol);
  return [
    TextSpan(
      text: text,
    ),
  ];
}
