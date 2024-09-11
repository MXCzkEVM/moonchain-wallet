import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'message_info.dart';

Future<bool?> showSignMessageDialog(
  BuildContext context, {
  String? title,
  required String networkName,
  required String message,
  VoidCallback? onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxcAppBarEvenly.title(
          titleText: title ?? '',
          action: Container(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: const Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
        MessageInfo(
          message: message,
          networkName: networkName,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}
