import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class DAppHooksInformation extends StatelessWidget {
  final List<InlineSpan> texts;
  const DAppHooksInformation({
    Key? key,
    required this.texts,
  }) : super(key: key);

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
          children: texts),
      preferBelow: false,
      child: Icon(
        Icons.info_rounded,
        color: ColorsTheme.of(context).iconPrimary,
      ),
    );
  }
}
