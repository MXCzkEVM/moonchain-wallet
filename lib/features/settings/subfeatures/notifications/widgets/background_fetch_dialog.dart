import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showBackgroundFetchAlertDialog({
  required BuildContext context,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        backgroundColor: ColorsTheme.of(context).cardBackground,
        title: Text(
          FlutterI18n.translate(context, 'background_fetch_notice_title'),
          style: FontTheme.of(context).h6().copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(
          bottom: Sizes.space2XLarge,
          left: Sizes.spaceNormal,
          right: Sizes.spaceNormal,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterI18n.translate(context, 'background_fetch_notice_text'),
              style: FontTheme.of(context).body1(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceXLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MxcButton.primaryWarning(
                  key: const ValueKey('acknowledgeButton'),
                  title: FlutterI18n.translate(context, 'acknowledge'),
                  titleColor: ColorsTheme.of(context).textBlack200,
                  size: AxsButtonSize.xl,
                  width: 120,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
