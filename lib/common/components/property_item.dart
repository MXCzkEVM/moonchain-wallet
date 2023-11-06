import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class PropertyItem extends StatelessWidget {
  final String title;
  final String value;

  const PropertyItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Sizes.spaceXSmall),
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.spaceXSmall,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: FontTheme.of(context).body2.secondary(),
        ),
        const SizedBox(
          width: Sizes.space2XSmall,
        ),
        Text(
          value,
          style: FontTheme.of(context).body1.primary(),
        ),
      ]),
    );
  }
}
