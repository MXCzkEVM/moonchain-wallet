import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showPermissionUseCasesBottomSheet(
  BuildContext context, {
  required Permission permission,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.only(
          top: Sizes.spaceNormal, bottom: Sizes.space3XLarge),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).layerSheetBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Sizes.spaceXLarge,
        ),
        child: Column(
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
              style: FontTheme.of(context).body2.primary(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: Sizes.spaceXLarge,
            ),
            MxcButton.secondary(
              key: const ValueKey('notNow'),
              title: translate('not_now'),
              onTap: () => Navigator.of(context).pop(false),
              size: AxsButtonSize.xl,
            ),
            const SizedBox(
              height: Sizes.spaceXLarge,
            ),
            MxcButton.primary(
              key: const ValueKey('okAllow'),
              title: translate('ok_allow'),
              onTap: () => Navigator.of(context).pop(true),
              size: AxsButtonSize.xl,
            ),
          ],
        ),
      ),
    ),
  );
}

String getPermissionUseCaseText(Permission permission) {
  if (Permission.location == permission ||
      Permission.locationAlways == permission ||
      Permission.locationWhenInUse == permission) {
    return 'axs_location_permission_use_case';
  } else if (Permission.camera == permission) {
    return 'axs_camera_permission_use_case';
  } else if (Permission.storage == permission) {
    return 'axs_photos_permission_use_case';
  } else if (Permission.photos == permission) {
    return 'axs_photos_permission_use_case';
  } else {
    return 'axs_location_permission_use_case';
  }
}
