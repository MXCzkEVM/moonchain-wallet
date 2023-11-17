import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showCustomNetworkSwitchDialog(
    BuildContext context, String networkTitle) {
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
              child: Text(
                networkTitle.contains('https')
                    ? translate('custom_network_switch_without_title__notice')
                        .replaceFirst("{0}", networkTitle)
                    : translate('custom_network_switch_title__notice')
                        .replaceFirst("{0}", networkTitle),
                style: FontTheme.of(context).h6.primary(),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              translate('custom_network_switch_text__notice'),
              style: FontTheme.of(context).body2.primary(),
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: Sizes.spaceXLarge,
            ),
            MxcButton.primary(
              key: const ValueKey('gotItButton'),
              title: translate('got_it'),
              onTap: () {
                Navigator.of(context).pop(false);
              },
              size: AxsButtonSize.xl,
            ),
          ],
        ),
      ),
    ),
  );
}
