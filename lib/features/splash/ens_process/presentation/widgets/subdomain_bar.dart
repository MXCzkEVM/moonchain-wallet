import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'cube_bar.dart';

class SubDomainBar extends StatelessWidget {
  const SubDomainBar({
    Key? key,
    this.domain,
  }) : super(key: key);

  final String? domain;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CubeBarPainter(
        contentColor: const Color(0xFF3B8A3D),
        shadowColor: const Color(0xFF2B6F2D),
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(6),
        child: Text(
          domain ?? 'e.g. elonmusk.mxc',
          style: FontTheme.of(context).caption1.white(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
