import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:moonchain_wallet/features/dapps/subfeatures/open_dapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<ScanResult?> showBlueberryRingsBottomSheet(
  BuildContext context,
) {
  return showBaseBottomSheet<ScanResult>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxcAppBarEvenly.title(
          titleText: FlutterI18n.translate(context, 'nearby_blueberry_rings'),
          action: Container(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: const Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(null),
            ),
          ),
        ),
        const BlueberryDeviceInfo(),
        const SizedBox(height: 10),
      ],
    ),
  );
}
