import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showWiFiHooksBackgroundFetchAlertBottomSheet({
  required BuildContext context,
}) async {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: 'background_fetch_notice_title',
    hasCloseButton: false,
    widgets: [
      Column(
        children: [
          Text(
            translate(
              'wifi_location_background_fetch_notice_text',
            ),
            style: FontTheme.of(context, listen: false)
                .body1
                .primary()
                .copyWith(),
            softWrap: true,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(
            height: Sizes.spaceNormal,
          ),
          MxcButton.primary(
            key: const ValueKey('acknowledgeButton'),
            title: translate('acknowledge'),
            onTap: () {
              Navigator.of(context).pop(true);
            },
            size: MXCWalletButtonSize.xl,
          ),
        ],
      ),
    ],
  );
}
