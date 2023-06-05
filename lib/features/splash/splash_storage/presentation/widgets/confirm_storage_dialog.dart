import 'package:datadashwallet/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum StorageType { telegram, wechat, mnemonic, email, others }

void showConfirmStorageAlertDialog(
  BuildContext context, {
  StorageType type = StorageType.others,
  VoidCallback? onOkTap,
  VoidCallback? onNoTap,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(FlutterI18n.translate(context, 'alert')),
      content: type == StorageType.wechat
          ? const SaveToHereTip()
          : const ConfirmToSaveTip(),
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

class SaveToHereTip extends StatelessWidget {
  const SaveToHereTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Save to here",
          style: FontTheme.of(context).h5.primary(),
          textAlign: TextAlign.center,
        ),
        Container(
          alignment: Alignment.centerRight,
          child: SvgPicture.asset(
            "assets/svg/curve_arrow.svg",
            colorFilter: filterFor(ColorsTheme.of(context).purpleMain),
          ),
        )
      ],
    );
  }
}

class ConfirmToSaveTip extends StatelessWidget {
  const ConfirmToSaveTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(FlutterI18n.translate(context, 'save_related_app'));
  }
}
