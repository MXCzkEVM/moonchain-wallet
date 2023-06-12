import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class GreyContainer extends StatelessWidget {
  EdgeInsets? padding;
  final Widget child;
  GreyContainer({Key? key, required this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: ColorsTheme.of(context).box,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: child,
    );
  }
}
