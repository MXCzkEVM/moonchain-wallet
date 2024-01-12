import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SwitchRowItem extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool)? onChanged;
  final bool enabled;
  const SwitchRowItem(
      {super.key,
      required this.title,
      required this.value,
      this.onChanged,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: FontTheme.of(context).body2.primary(),
        ),
        const Spacer(),
        const SizedBox(
          width: 16,
        ),
        CupertinoSwitch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
