import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CardVerticalLayout extends AppCardLayout {
  const CardVerticalLayout({
    Key? key,
    required DAppCard child,
    VoidCallback? onTap,
  }) : super(
          key: key,
          child: child,
          onTap: onTap,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          FlutterI18n.translate(context, child.description),
          style: FontTheme.of(context).subtitle2.white(),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
        const SizedBox(height: 10),
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
        const Spacer(),
        getImage(),
        const Spacer(),
      ],
    );
  }
}
