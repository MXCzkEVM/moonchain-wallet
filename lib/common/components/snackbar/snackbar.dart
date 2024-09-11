import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'linear_bar_animation.dart';

enum SnackBarType { success, fail, warning }

enum SnackBarPosition {
  top,
  bottom,
}

void showSnackBar({
  required BuildContext context,
  required String content,
  String? title,
  SnackBarType? type = SnackBarType.success,
  String? buttonTitle,
  void Function()? buttonOnTap,
  SnackBarPosition? snackBarPosition,
  action,
}) {
  if (buttonOnTap != null || buttonTitle != null) {
    assert(buttonOnTap != null && buttonTitle != null,
        'Button onTap & title should both be specified if one of them is specified.');
  }

  final isTitleAvailable = title != null;

  Color getColor() {
    switch (type) {
      case SnackBarType.success:
        return ColorsTheme.of(context, listen: false).greenSuccess;
      case SnackBarType.fail:
        return ColorsTheme.of(context, listen: false).error;
      case SnackBarType.warning:
        return ColorsTheme.of(context, listen: false).warning;
      default:
        return ColorsTheme.of(context, listen: false).warning;
    }
  }

  Color getShadowColor() {
    switch (type) {
      case SnackBarType.success:
        return ColorsTheme.of(
          context,
          listen: false,
        ).successShadow;
      case SnackBarType.fail:
        return ColorsTheme.of(
          context,
          listen: false,
        ).errorShadow;
      case SnackBarType.warning:
        return ColorsTheme.of(
          context,
          listen: false,
        ).warningShadow;
      default:
        return ColorsTheme.of(
          context,
          listen: false,
        ).warningShadow;
    }
  }

  TextStyle getContentStyle() {
    if (isTitleAvailable) {
      return FontTheme.of(
        context,
        listen: false,
      ).caption1().copyWith(
            color: ColorsTheme.of(context, listen: false).lightGray,
          );
    } else {
      return FontTheme.of(
        context,
        listen: false,
      ).body1().copyWith(
            color: ColorsTheme.of(context, listen: false).white,
          );
    }
  }

  final snackBar = SnackBar(
    elevation: 1000,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    margin: EdgeInsets.only(
      left: Sizes.spaceNormal,
      right: Sizes.spaceNormal,
      bottom: SnackBarPosition.top == snackBarPosition
          ? MediaQuery.of(
                context,
              ).size.height -
              250
          : 0,
    ),
    duration: const Duration(seconds: 4),
    padding: const EdgeInsets.all(0),
    backgroundColor: const Color(0XFF202020),
    content: ClipRRect(
      borderRadius: UIConfig.defaultBorderRadiusAll,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            left: -106 + Sizes.spaceXSmall,
            top: -80 + Sizes.spaceXSmall,
            child: Container(
              width: 212,
              height: 212,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    getShadowColor().withOpacity(0.21),
                    getShadowColor().withOpacity(0),
                  ],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
          ),
          LinearBarAnimation(color: getColor()),
          Padding(
            padding: const EdgeInsets.all(Sizes.spaceXSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Sizes.spaceXSmall),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF303746).withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      SnackBarType.success == type
                          ? MxcIcons.check_mark
                          : SnackBarType.fail == type
                              ? Icons.cancel_sharp
                              : MxcIcons.warning_1,
                      color: getColor(),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: Sizes.spaceXSmall),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: Sizes.spaceXSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isTitleAvailable
                            ? Text(
                                title,
                                style: FontTheme.of(
                                  context,
                                  listen: false,
                                ).subtitle2().copyWith(
                                      color:
                                          ColorsTheme.of(context, listen: false)
                                              .white,
                                    ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                              )
                            : Container(),
                        Text(
                          content,
                          style: getContentStyle(),
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ),
                if (buttonTitle != null && buttonOnTap != null) ...[
                  Container(
                    alignment: AlignmentDirectional.centerEnd,
                    width: MediaQuery.of(
                          context,
                        ).size.width *
                        0.15,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          buttonOnTap();
                        },
                        child: Text(
                          buttonTitle,
                          style: FontTheme.of(context, listen: false)
                              .subtitle1()
                              .copyWith(
                                color: getColor().withOpacity(0.4),
                              ),
                        ),
                      ),
                    ),
                  )
                ] else
                  Container()
              ],
            ),
          ),
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
