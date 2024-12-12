import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:moonchain_wallet/features/dapps/subfeatures/open_dapp/widgets/typed_message_info.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showTypedMessageDialog(
  BuildContext context, {
  String? title = '',
  required String networkName,
  required String primaryType,
  required Map<String, dynamic> message,
  VoidCallback? onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: false,
    widgets: [
      TypeMessageInfo(
        message: message,
        networkName: networkName,
        primaryType: primaryType,
        onTap: onTap,
      ),
      const SizedBox(height: 10),
    ],
  );
}
