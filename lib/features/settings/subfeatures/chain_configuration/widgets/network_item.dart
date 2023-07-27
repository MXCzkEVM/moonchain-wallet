import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class NetworkItem extends StatelessWidget {
  const NetworkItem(
      {super.key,
      required this.networkLogo,
      required this.networkName,
      required this.isDefault,
      this.onTap});

  final String networkLogo;
  final String networkName;
  final bool isDefault;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceNormal),
      child: Row(children: [
        SvgPicture.asset(
          networkLogo,
          height: 24,
          width: 24,
        ),
        const SizedBox(
          width: Sizes.spaceXLarge,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              networkName,
              style: FontTheme.of(context).body2.primary(),
            ),
            isDefault
                ? Text(
                    FlutterI18n.translate(context, 'default'),
                    style: FontTheme.of(context).body1().copyWith(color: ColorsTheme.of(context).textWhite100),
                  )
                : Container(),
          ],
        ),
        const Spacer(),
        if (onTap != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceNormal),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ColorsTheme.of(context).white400,
            ),
          ),
      ]),
    );
  }
}
