import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/presentation/open_app/open_app_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class AppCardLayout extends StatelessWidget {
  const AppCardLayout({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  const factory AppCardLayout.horizotal({
    Key? key,
    required DAppCard child,
    VoidCallback? onTap,
  }) = CardHorizontalLayout;

  const factory AppCardLayout.vertical({
    Key? key,
    required DAppCard child,
    VoidCallback? onTap,
  }) = CardVerticalLayout;

  final DAppCard child;
  final VoidCallback? onTap;

  double getHight() {
    if (child.direction == CardAxis.horizontal) {
      return 130;
    } else if (child.direction == CardAxis.vertical) {
      return 247;
    } else {
      return double.infinity;
    }
  }

  Widget buildContent(BuildContext context);

  Widget getImage() {
    if (child.image!.contains('.svg')) {
      return SvgPicture.asset(
        child.image!,
        height: child.imageHeight,
      );
    } else if (child.image!.contains(RegExp(r'.png|.jpg'))) {
      return Image(
        image: AssetImage(
          child.image!,
        ),
        height: child.imageHeight,
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
          color: child.backgroundColor ?? const Color(0xFF292929),
          gradient: child.backgroundGradient,
        ),
        child: InkWell(
          onTap: child.url != null && child.url!.isNotEmpty
              ? () => Navigator.of(context).push(
                    route.featureDialog(
                      maintainState: false,
                      OpenAppPage(dapp: child),
                    ),
                  )
              : null,
          child: buildContent(context),
        ),
      ),
    );
  }
}
