import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class GreyContainer extends StatelessWidget {
  EdgeInsetsDirectional? padding;
  final Widget child;
  final double? height;
  final double? width;
  GreyContainer(
      {Key? key, required this.child, this.padding, this.height, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
          color: ColorsTheme.of(context).layerSheetBackground,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: child,
    );
  }
}
