import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showNoBalanceDialog(
  BuildContext context,
) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        backgroundColor: ColorsTheme.of(context).cardBackground,
        title: Text(
          FlutterI18n.translate(context, 'no_balance'),
          style: FontTheme.of(context).h6().copyWith(
                fontWeight: FontWeight.w500,
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
            Text(
              FlutterI18n.translate(context, 'no_balance_tip'),
              style: FontTheme.of(context).body1(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceXLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MxcButton.secondary(
                  key: const ValueKey('cancelButton'),
                  title: FlutterI18n.translate(context, 'skip'),
                  size: MXCWalletButtonSize.xl,
                  width: 120,
                  onTap: () => Navigator.of(context).pop(false),
                ),
                MxcButton.primary(
                  key: const ValueKey('okayButton'),
                  title: FlutterI18n.translate(context, 'receive'),
                  titleColor: ColorsTheme.of(context).textBlack200,
                  size: MXCWalletButtonSize.xl,
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
