import 'package:mxc_ui/mxc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    Key? key,
    required this.icon,
    this.size,
  }) : super(key: key);

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFFFFF).withOpacity(0.32),
      ),
      child: Icon(
        icon,
        color: ColorsTheme.of(context).white100,
        size: size,
      ),
    );
  }
}
