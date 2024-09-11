import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showPermissionUseCasesBottomSheet(
  BuildContext context, {
  required Permission permission,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: Sizes.spaceNormal,
              end: Sizes.spaceNormal,
              bottom: Sizes.space2XLarge),
          child: MxcAppBarEvenly.title(
            titleText: translate('permission_use_cases'),
          ),
        ),
        Text(
          translate(getPermissionUseCaseText(permission)),
          style: FontTheme.of(context, listen: false).body2.primary(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.secondary(
          key: const ValueKey('notNow'),
          title: translate('not_now'),
          onTap: () => Navigator.of(context).pop(false),
          size: MXCWalletButtonSize.xl,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.primary(
          key: const ValueKey('okAllow'),
          title: translate('ok_allow'),
          onTap: () => Navigator.of(context).pop(true),
          size: MXCWalletButtonSize.xl,
        ),
      ],
    ),
  );
}

String getPermissionUseCaseText(Permission permission) {
  if (Permission.location == permission ||
      Permission.locationAlways == permission ||
      Permission.locationWhenInUse == permission) {
    return 'moonchain_location_permission_use_case';
  } else if (Permission.camera == permission) {
    return 'moonchain_camera_permission_use_case';
  } else if (Permission.storage == permission) {
    return 'moonchain_storage_permission_use_case';
  } else if (Permission.photos == permission) {
    return 'moonchain_photos_permission_use_case';
  } else {
    return 'moonchain_location_permission_use_case';
  }
}
