import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'speed_up_cancel_bottom_sheet_info.dart';

Future<bool?> showSpeedUpDialog(BuildContext context,
        {required String estimatedFee,
        required String maxFee,
        required String symbol}) =>
    showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 44),
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
              titleText: FlutterI18n.translate(context, 'speed_up'),
              action: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: const Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
            SpeedUpCancelBottomSheetInfo(
              estimatedFee: estimatedFee,
              maxFee: maxFee,
              symbol: symbol,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
