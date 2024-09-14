import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showWarningDialog({
  required BuildContext context,
  required String title,
  Color? titleColor,
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
        icon: Icon(
          Icons.warning_rounded,
          color: ColorsTheme.of(context).buttonCritical,
          size: 56,
        ),
        title: Text(
          FlutterI18n.translate(context, title),
          style: FontTheme.of(context).h6().copyWith(
                fontWeight: FontWeight.w500,
                color: titleColor ?? ColorsTheme.of(context).buttonCritical,
              ),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(
          top: Sizes.spaceSmall,
          bottom: Sizes.space2XLarge,
          left: Sizes.spaceNormal,
          right: Sizes.spaceNormal,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (content != null)
              Text(
                FlutterI18n.translate(context, content),
                style: FontTheme.of(context).body1(),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: Sizes.spaceXLarge),
            MxcButton.primaryWarning(
              key: const ValueKey('deleteButton'),
              title: FlutterI18n.translate(context, ok ?? 'delete'),
              titleColor: ColorsTheme.of(context).textBlack200,
              size: MXCWalletButtonSize.xl,
              onTap: () => Navigator.of(context).pop(true),
              edgeType: UIConfig.settingsScreensButtonsEdgeType,
            ),
            const SizedBox(height: Sizes.spaceNormal),
            MxcButton.secondary(
              key: const ValueKey('cancelButton'),
              title: FlutterI18n.translate(context, cancel ?? 'cancel'),
              size: MXCWalletButtonSize.xl,
              onTap: () => Navigator.of(context).pop(false),
              edgeType: UIConfig.settingsScreensButtonsEdgeType,
            ),
          ],
        ),
      );
    },
  );
}
