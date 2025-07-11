import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:moonchain_wallet/features/dapps/subfeatures/open_dapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<ScanResult?> showBluetoothDevicesBottomSheet(
  BuildContext context,
  String title,
) {
  return showBaseBottomSheet<ScanResult>(
    context: context,
    bottomSheetTitle: title,
    closeButtonReturnValue: null,
    widgets: [
      const BlueberryDeviceInfo(),
      const SizedBox(height: 10),
    ],
  );
}
