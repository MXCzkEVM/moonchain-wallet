import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  String? cancel,
  String? ok,
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
          '${FlutterI18n.translate(context, title)}?',
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
              FlutterI18n.translate(context, content ?? ''),
              style: FontTheme.of(context).body1(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceXLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MxcButton.secondary(
                  key: const ValueKey('cancelButton'),
                  title: FlutterI18n.translate(context, cancel ?? 'cancel'),
                  size: MXCWalletButtonSize.xl,
                  width: 120,
                  onTap: () => Navigator.of(context).pop(false),
                  edgeType: UIConfig.settingsScreensButtonsEdgeType,
                ),
                MxcButton.primaryWarning(
                  key: const ValueKey('deleteButton'),
                  title: FlutterI18n.translate(context, ok ?? 'delete'),
                  titleColor: ColorsTheme.of(context).textBlack200,
                  size: MXCWalletButtonSize.xl,
                  width: 120,
                  onTap: () => Navigator.of(context).pop(true),
                  edgeType: UIConfig.settingsScreensButtonsEdgeType,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
