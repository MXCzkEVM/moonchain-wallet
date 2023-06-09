import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'card_medium_horizontal_layout.dart';
import 'card_large_vertical_layout.dart';

import '../../entities/app_card_entity.dart';

abstract class AppCardLayout extends StatelessWidget {
  const AppCardLayout({
    Key? key,
    required this.app,
  }) : super(key: key);

  const factory AppCardLayout.mediumHorizotal({
    Key? key,
    required AppCardEntity app,
  }) = CarMediumHorizontalLayout;

  const factory AppCardLayout.largeVertical({
    Key? key,
    required AppCardEntity app,
  }) = CardLargeVerticalLayout;

  final AppCardEntity app;

  double getHight() {
    if (app.direction == CardAxis.horizontal) {
      return 113;
    } else if (app.direction == CardAxis.vertical) {
      return 247;
    } else {
      return double.infinity;
    }
  }

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: getHight(),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: app.backgroundColor ?? const Color(0xFF292929),
          gradient: app.backgroundGradient,
        ),
        child: buildContent(context),
      ),
    );
  }
}
