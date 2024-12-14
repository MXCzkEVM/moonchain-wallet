import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showLocationPermissionBottomSheet({
  required BuildContext context,
  required Function openLocationSettings,
}) async {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: 'location_permission_required_title',
    hasCloseButton: false,
    widgets: [
      Column(
        children: [
          Text(
            translate(
              'location_permission_required_text',
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
            key: const ValueKey('openLocationSettingsButton'),
            title: translate('open_settings'),
            onTap: () {
              openLocationSettings();
              Navigator.of(context).pop(true);
            },
            size: MXCWalletButtonSize.xl,
          ),
          const SizedBox(
            height: Sizes.spaceNormal,
          ),
          MxcButton.secondary(
            key: const ValueKey('cancelButton'),
            title: translate('cancel'),
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
