import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class ErrorTip extends StatelessWidget {
  const ErrorTip(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/svg/ic_alert.svg'),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            FlutterI18n.translate(context, text),
            style: FontTheme.of(context)
                .subtitle1()
                .copyWith(color: ColorsTheme.of(context).errorText),
          ),
        )
      ],
    );
  }
}
