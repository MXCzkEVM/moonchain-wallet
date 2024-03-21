import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showDAppHooksBackgroundFetchAlertDialog({
  required BuildContext context,
}) async {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxcAppBarEvenly.title(
            titleText: translate('background_fetch_notice_title'),
            useContentPadding: false,
            textFieldFlex: 5,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: Sizes.spaceXLarge,
            ),
            child: Column(
              children: [
                Text(
                  translate(
                    'wifi_location_background_fetch_notice_text',
                  ),
                  style: FontTheme.of(context).body1.primary().copyWith(),
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
                  size: AxsButtonSize.xl,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
