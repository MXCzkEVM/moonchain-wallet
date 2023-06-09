import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class AddressBar extends StatelessWidget {
  const AddressBar({
    Key? key,
    this.address,
  }) : super(key: key);

  final String? address;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: Stack(
        children: [
          Positioned(
            left: -8,
            bottom: -5,
            child: SvgPicture.asset(
              'assets/svg/ens/orange_shadow_bar.svg',
              width: 302,
            ),
          ),
          Center(
            child: Container(
              height: 30,
              width: 290,
              color: const Color(0xFFB68238),
              alignment: Alignment.center,
              child: Text(
                address ?? '0xC4ba135513F17438djefB02d7948A22a3177e07E',
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
