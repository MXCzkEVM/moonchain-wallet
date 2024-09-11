import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showCustomNetworkSwitchDialog(
    BuildContext context, String networkTitle) {
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
          child: Text(
            networkTitle.contains('https')
                ? translate('custom_network_switch_without_title__notice')
                    .replaceFirst("{0}", networkTitle)
                : translate('custom_network_switch_title__notice')
                    .replaceFirst("{0}", networkTitle),
            style: FontTheme.of(context, listen: false).h6.primary(),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          translate('custom_network_switch_text__notice'),
          style: FontTheme.of(context, listen: false).body2.primary(),
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
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
      ],
    ),
  );
}
