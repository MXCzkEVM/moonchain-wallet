import 'package:moonchain_wallet/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showSwitchNetworkDialog(
  BuildContext context, {
  required Network network,
  required void Function(Network network) onSwitch,
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
            titleText: translate('new_network_added'),
          ),
        ),
        Text(
          translate('x_is_now_available')
              .replaceFirst('{0}', network.label ?? network.web3RpcHttpUrl),
          style: FontTheme.of(context, listen: false).body2.primary(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.secondary(
          key: const ValueKey('closeButton'),
          title: translate('close'),
          onTap: () => Navigator.of(context).pop(false),
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.primary(
          key: const ValueKey('switchToNetwork'),
          title: translate('switch_to_network'),
          onTap: () {
            onSwitch(network);
          },
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
      ],
    ),
  );
}
