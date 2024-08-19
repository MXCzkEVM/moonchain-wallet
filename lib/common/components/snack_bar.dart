import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'c.dart';

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
  SnackBarAction? action,
  AnimationController? animation,
}) {
  assert(action?.textColor == null, '\'action\' text color should be null');
  SnackBarAction? updateAction = action;

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

  if (action != null && action.textColor == null) {
    updateAction = SnackBarAction(
      label: action.label,
      onPressed: action.onPressed,
      textColor: getColor().withOpacity(0.4),
    );
  }

  Color getShadowColor() {
    switch (type) {
      case SnackBarType.success:
        return ColorsTheme.of(context, listen: false).successShadow;
      case SnackBarType.fail:
        return ColorsTheme.of(context, listen: false).errorShadow;
      case SnackBarType.warning:
        return ColorsTheme.of(context, listen: false).warningShadow;
      default:
        return ColorsTheme.of(context, listen: false).warningShadow;
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
    // animation: animation,
    elevation: 1000,
    shape: RoundedBottomBorder(
      bottomBorder:
          BorderSide(color: getColor(), width: 2, style: BorderStyle.solid),
      // animationValue: animation.value
    ),
    margin: EdgeInsets.only(
      left: Sizes.spaceNormal,
      right: Sizes.spaceNormal,
      bottom: SnackBarType.warning == type
          ? MediaQuery.of(context).size.height - 250
          : 0,
    ),
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
                  // center: Alignment.centerLeft, // Center the gradient on the icon
                  // radius: 20,

                  colors: [
                    getShadowColor().withOpacity(0.21),
                    getShadowColor().withOpacity(0),
                  ],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: LinearProgressIndicator(
              color: Colors.red,
              value: 0.5,
              minHeight: 50,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
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
                      Text(
                        content,
                        style: getContentStyle(),
                        textAlign: TextAlign.start,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
    // action: updateAction,
  );

  animation?.forward();
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
