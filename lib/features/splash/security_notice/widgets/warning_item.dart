import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'circle_icon.dart';

class WarningItem extends StatelessWidget {
  const WarningItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.iconSize,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String subTitle;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleIcon(
          icon: icon,
          size: iconSize,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            FlutterI18n.translate(context, title),
            style: FontTheme.of(context).body1.white().copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            FlutterI18n.translate(context, subTitle),
            style: FontTheme.of(context).subtitle1().copyWith(
                  color: ColorsTheme.of(context).textGrey1,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
