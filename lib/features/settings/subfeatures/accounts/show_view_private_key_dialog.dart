import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

void showViewPrivateKeyDialog(
    {required BuildContext context,
    required String privateKey,
    required Function(String) onCopy}) {
  showBaseBottomSheet<void>(
    context: context,
    bottomSheetTitle: 'private_key',
    closeButtonReturnValue: false,
    widgets: [
      SingleLineInfoItem(
        title: 'private_key',
        value: privateKey,
        valueActionIcon: IconButton(
            icon: Icon(
              MxcIcons.copy,
              size: 20,
              color: ColorsTheme.of(context, listen: false).iconGrey1,
            ),
            onPressed: () {
              onCopy(privateKey);
              Navigator.of(context).pop();
            }),
      ),
      const SizedBox(height: Sizes.spaceXSmall),
      MxcButton.primary(
        key: const ValueKey('doneButton'),
        title: FlutterI18n.translate(context, 'done'),
        onTap: () => Navigator.of(context).pop(false),
        size: MXCWalletButtonSize.xl,
      ),
    ],
  );
}
