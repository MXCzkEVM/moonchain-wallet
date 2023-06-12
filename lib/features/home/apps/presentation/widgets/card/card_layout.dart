import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/presentation/open_app/open_app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'card_horizontal_layout.dart';
import 'card_vertical_layout.dart';

import '../../../entities/app_card_entity.dart';

abstract class AppCardLayout extends StatelessWidget {
  const AppCardLayout(
    this.app, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  const factory AppCardLayout.horizotal(
    AppCardEntity app, {
    Key? key,
    VoidCallback? onTap,
  }) = CardHorizontalLayout;

  const factory AppCardLayout.vertical(
    AppCardEntity app, {
    Key? key,
    VoidCallback? onTap,
  }) = CardVerticalLayout;

  final AppCardEntity app;
  final VoidCallback? onTap;

  double getHight() {
    if (app.direction == CardAxis.horizontal) {
      return 130;
    } else if (app.direction == CardAxis.vertical) {
      return 247;
    } else {
      return double.infinity;
    }
  }

  Widget buildContent(BuildContext context);

  Widget getImage() {
    if (app.image!.contains('.svg')) {
      return SvgPicture.asset(
        app.image!,
        height: app.imageHeight,
      );
    } else if (app.image!.contains(RegExp(r'.png|.jpg'))) {
      return Image(
        image: AssetImage(
          app.image!,
        ),
        height: app.imageHeight,
      );
    } else {
      throw UnimplementedError();
    }
  }

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
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            route.featureDialog(
              OpenAppPage(
                url: app.url,
              ),
            ),
          ),
          child: buildContent(context),
        ),
      ),
    );
  }
}
