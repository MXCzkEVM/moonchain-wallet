import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/presentation/widgets/card/card_layout.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../entities/app_card_entity.dart';

class CardVerticalLayout extends AppCardLayout {
  const CardVerticalLayout(
    AppCardEntity app, {
    Key? key,
    VoidCallback? onTap,
  }) : super(
          app,
          key: key,
          onTap: onTap,
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
          textAlign: TextAlign.center,
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
        const Spacer(),
        getImage(),
        const Spacer(),
      ],
    );
  }
}
