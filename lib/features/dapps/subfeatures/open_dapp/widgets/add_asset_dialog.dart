import 'package:moonchain_wallet/features/dapps/subfeatures/open_dapp/widgets/add_asset_info.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showAddAssetDialog(
  BuildContext context, {
  String? title = '',
  required WatchAssetModel token,
  VoidCallback? onTap,
}) {
  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: false,
    widgets: [
      AddAssetInfo(
        token: token,
        onTap: onTap,
      ),
      const SizedBox(height: 10),
    ],
  );
}
