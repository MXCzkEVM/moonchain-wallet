import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum SnackBarType { success, fail, warning }

void showSnackBar({
  required BuildContext context,
  required String content,
  SnackBarType? type = SnackBarType.success,
  SnackBarAction? action,
}) {
  Color getColor() {
    switch (type) {
      case SnackBarType.success:
        return ColorsTheme.of(context, listen: false).systemStatusActive;
      case SnackBarType.fail:
        return ColorsTheme.of(context, listen: false).systemStatusInActive;
      default:
        return ColorsTheme.of(context, listen: false).systemStatusNotCritical;
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
      bottom: MediaQuery.of(context).size.height - 250,
    ),
    padding: const EdgeInsets.all(Sizes.spaceXSmall),
    backgroundColor: getColor(),
    content: Row(
      children: [
        if (SnackBarType.warning != type)
          Icon(
            SnackBarType.success == type
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: ColorsTheme.of(context, listen: false).iconBlack200,
            size: 20,
          ),
        const SizedBox(width: Sizes.space2XSmall),
        Expanded(
          child: Text(
            content,
            style: FontTheme.of(context, listen: false).body1().copyWith(
                color: ColorsTheme.of(context, listen: false).snackbarText),
            textAlign: TextAlign.start,
            softWrap: true,
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    action: action,
  );
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
