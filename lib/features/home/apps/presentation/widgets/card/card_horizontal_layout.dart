import 'dart:ui';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/presentation/widgets/card/card_layout.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../entities/app_card_entity.dart';

class CardHorizontalLayout extends AppCardLayout {
  const CardHorizontalLayout(
    AppCardEntity app, {
    Key? key,
    VoidCallback? onTap,
  }) : super(
          app,
          key: key,
          onTap: onTap,
        );

  Widget layout(
    BuildContext context,
    List<Widget> children,
  ) {
    if (app.contentAlgin == CardContentAlgin.leftBottom) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      child: layout(
        context,
        [
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
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
