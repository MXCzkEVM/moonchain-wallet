import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/widgets/card/app_card_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../entities/app_card_entity.dart';

class CardLargeVerticalLayout extends AppCardLayout {
  const CardLargeVerticalLayout({
    Key? key,
    required AppCardEntity app,
  }) : super(
          key: key,
          app: app,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          app.description,
          style: FontTheme.of(context).subtitle2.white(),
          softWrap: true,
        ),
        const SizedBox(height: 10),
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
        if (app.image!.contains('.svg'))
          SvgPicture.asset(
            app.image!,
            height: app.imageHeight,
          ),
        if (app.image!.contains(RegExp(r'.png|.jpg')))
          Image(
            image: AssetImage(
              app.image!,
            ),
            height: app.imageHeight,
          ),
      ],
    );
  }
}
