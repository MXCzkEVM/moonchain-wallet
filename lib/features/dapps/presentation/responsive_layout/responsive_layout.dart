import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'dapps_layout/card_item.dart';
import 'dapp_card_layout.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => const DappCardLayout(),
      tablet: (BuildContext context) => const DappCardLayout(
        crossAxisCount: CardCrossAxisCount.tablet,
        mainAxisCount: CardMainAxisCount.tablet,
      ),
    );
  }
}
