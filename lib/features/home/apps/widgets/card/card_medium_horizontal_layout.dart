import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/widgets/card/app_card_layout.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../entities/app_card_entity.dart';

class CarMediumHorizontalLayout extends AppCardLayout {
  const CarMediumHorizontalLayout({
    Key? key,
    required AppCardEntity app,
  }) : super(
          key: key,
          app: app,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientText(
          app.name,
          gradient: LinearGradient(
            colors: app.nameColor ??
                [
                  Colors.white,
                  Colors.white,
                ],
          ),
          style: FontTheme.of(context).h5().copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          app.description,
          style: FontTheme.of(context).subtitle2.white(),
          softWrap: true,
        ),
      ],
    );
  }
}
