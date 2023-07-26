import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showDeleteDialog(
  BuildContext context,
) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        backgroundColor: ColorsTheme.of(context).box,
        title: Text(
          '${FlutterI18n.translate(context, 'delete_recipient')}?',
          style: FontTheme.of(context).h6().copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(
          top: Sizes.spaceXLarge,
          bottom: Sizes.space2XLarge,
          left: Sizes.spaceNormal,
          right: Sizes.spaceNormal,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MxcButton.secondary(
              key: const ValueKey('cancelButton'),
              title: FlutterI18n.translate(context, 'cancel'),
              size: MxcButtonSize.xl,
              width: 120,
              onTap: () => Navigator.of(context).pop(false),
            ),
            MxcButton.primaryWarning(
              key: const ValueKey('deleteButton'),
              title: FlutterI18n.translate(context, 'delete'),
              titleColor: ColorsTheme.of(context).textBlack200,
              size: MxcButtonSize.xl,
              width: 120,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    },
  );
}
