import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CardHorizontalLayout extends AppCardLayout {
  const CardHorizontalLayout({
    Key? key,
    required DAppCard child,
    VoidCallback? onTap,
  }) : super(
          key: key,
          child: child,
          onTap: onTap,
        );

  Widget layout(
    BuildContext context,
    List<Widget> children,
  ) {
    if (child.contentAlgin == CardContentAlgin.leftBottom) {
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
            child.name,
            gradient: LinearGradient(
              colors: child.nameColor ??
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
            FlutterI18n.translate(context, child.description),
            style: FontTheme.of(context).subtitle2.white(),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
