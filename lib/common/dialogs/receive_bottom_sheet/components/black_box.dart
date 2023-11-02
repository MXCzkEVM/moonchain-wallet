import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BlackBox extends StatelessWidget {
  const BlackBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).grey6,
        borderRadius: const BorderRadius.all(Radius.circular(35)),
      ),
      child: child,
    );
  }
}
