import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'speed_up_cancel_bottom_sheet_info.dart';

Future<bool?> showCancelDialog(BuildContext context,
        {required String estimatedFee,
        required String maxFee,
        required String symbol}) =>
    showBaseBottomSheet<bool>(
      context: context,
      bottomSheetTitle: 'cancel',
      closeButtonReturnValue: false,
      widgets: [
        SpeedUpCancelBottomSheetInfo(
          estimatedFee: estimatedFee,
          maxFee: maxFee,
          symbol: symbol,
        ),
        const SizedBox(height: 10),
      ],
    );
