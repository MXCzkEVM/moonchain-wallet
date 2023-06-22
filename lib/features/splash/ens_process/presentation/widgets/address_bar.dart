import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'cube_bar.dart';

class AddressBar extends StatelessWidget {
  const AddressBar({
    Key? key,
    this.address,
  }) : super(key: key);

  final String? address;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CubeBarPainter(
        contentColor: const Color(0xFFB68238),
        shadowColor: const Color(0xFF9A3B23),
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(6),
        child: Text(
          address ?? '0xC4ba135513F17438djefB02d7948A22a3177e07E',
          style: FontTheme.of(context).caption1.white(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
