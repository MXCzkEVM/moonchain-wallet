import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

void showConfirmStorageAlertDialog(
  BuildContext context, {
  VoidCallback? onOkTap,
  VoidCallback? onNoTap,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Alert'),
      content: const Text('Do you save the mnemonic to the related app?'),
      insetAnimationCurve: Curves.ease,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            onNoTap != null ? onNoTap() : null;
          },
          child: Text(FlutterI18n.translate(context, 'no')),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            onOkTap != null ? onOkTap() : null;
          },
          child: Text(FlutterI18n.translate(context, 'yes')),
        ),
      ],
    ),
  );
}
