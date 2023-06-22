import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'circle_icon.dart';

class WarningItem extends StatelessWidget {
  const WarningItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  final String icon;
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleIcon(icon: icon),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            FlutterI18n.translate(context, title),
            style: FontTheme.of(context).body2(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            FlutterI18n.translate(context, subTitle),
            style: FontTheme.of(context).subtitle1.secondary(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
