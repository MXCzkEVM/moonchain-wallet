import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<ScanResult?> showBlueberryRingsBottomSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ScanResult?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (BuildContext context, setState) {
        return Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 44),
          decoration: BoxDecoration(
            color: ColorsTheme.of(context).screenBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxcAppBarEvenly.title(
                titleText:
                    FlutterI18n.translate(context, 'nearby_blueberry_rings'),
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
      },
    ),
  );
}
