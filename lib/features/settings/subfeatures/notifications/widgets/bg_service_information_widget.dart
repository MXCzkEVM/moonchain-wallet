import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BGServiceInformation extends StatelessWidget {
  const BGServiceInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: ColorsTheme.of(context).mainRed,
      ),
      showDuration: const Duration(seconds: 5),
      triggerMode: TooltipTriggerMode.tap,
      richMessage: TextSpan(
          style: FontTheme.of(context)
              .subtitle1()
              .copyWith(color: ColorsTheme.of(context).chipTextBlack),
          children: [
            TextSpan(
              text: FlutterI18n.translate(context, 'experiencing_issues'),
              style: FontTheme.of(context)
                  .subtitle2()
                  .copyWith(color: ColorsTheme.of(context).chipTextBlack),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text:
                  FlutterI18n.translate(context, 'background_service_solution'),
              style: FontTheme.of(context)
                  .subtitle1()
                  .copyWith(color: ColorsTheme.of(context).chipTextBlack),
            ),
          ]),
      preferBelow: false,
      child: Icon(
        Icons.info_rounded,
        color: ColorsTheme.of(context).iconPrimary,
      ),
    );
  }
}
