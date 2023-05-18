import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

mixin SplashScreenMixin {
  Widget appLinearBackground({
    Widget? child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xff8D023F),
            Color(0xff09379E),
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: child,
    );
  }

  Widget appLogo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image(
          image: ImagesTheme.of(context).datadash,
        ),
        Text(
          'DataDash',
          style: FontTheme.of(context).h4().copyWith(
                color: ColorsTheme.of(context).white,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          'WALLET',
          style: FontTheme.of(context).h5().copyWith(
                color: ColorsTheme.of(context).white,
              ),
        ),
      ],
    );
  }
}
