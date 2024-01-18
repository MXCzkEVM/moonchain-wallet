import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SwitchRowItem extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool)? onChanged;
  final bool enabled;
  final Widget? textTrailingWidget;
  const SwitchRowItem(
      {super.key,
      required this.title,
      required this.value,
      this.onChanged,
      required this.enabled,
      this.textTrailingWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: FontTheme.of(context).body2.primary(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (textTrailingWidget != null) ...[
                const SizedBox(
                  width: Sizes.spaceXSmall,
                ),
                textTrailingWidget!
              ],
            ],
          ),
        ),
        const SizedBox(
          width: Sizes.spaceNormal,
        ),
        CupertinoSwitch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
