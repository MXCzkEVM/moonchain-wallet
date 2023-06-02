import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SubDomainBar extends StatelessWidget {
  const SubDomainBar({
    Key? key,
    this.domain,
  }) : super(key: key);

  final String? domain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 220,
      child: Stack(
        children: [
          Positioned(
            left: -5,
            bottom: -2,
            child: SvgPicture.asset(
              'assets/svg/green_shadow.svg',
              width: 200,
              height: 36,
            ),
          ),
          Center(
            child: Container(
              height: 24,
              width: 200,
              color: const Color(0xFF385F39),
              alignment: Alignment.center,
              child: Text(
                domain ?? 'ElonMusk.mxc',
                style: FontTheme.of(context).caption1.white(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
