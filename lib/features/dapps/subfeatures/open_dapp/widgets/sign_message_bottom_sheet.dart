import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';

import 'message_info.dart';

Future<bool?> showSignMessageDialog(
  BuildContext context, {
  String? title = '',
  required String networkName,
  required String message,
  VoidCallback? onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: false,
    widgets: [
        MessageInfo(
          message: message,
          networkName: networkName,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
  );
}
