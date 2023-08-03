import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChainLogoWidget extends StatelessWidget {
  const ChainLogoWidget({super.key, required this.logo});

  final String logo;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      logo,
      height: 24,
      width: 24,
    );
  }
}
