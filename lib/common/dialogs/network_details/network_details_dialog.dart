import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../common.dart';

Future<bool?> showNetworkDetailsDialog(
  BuildContext context, {
  required Network network,
}) {
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
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Sizes.spaceXLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: Sizes.spaceNormal,
                  end: Sizes.spaceNormal,
                  bottom: 0),
              child: MxcAppBarEvenly.title(
                titleText: network.label ?? network.web3RpcHttpUrl,
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Text(
            //       translate(
            //         'want_to_add_this_network',
            //       ),
            //       style: FontTheme.of(context)
            //           .body2
            //           .primary()
            //           .copyWith(fontWeight: FontWeight.w600),
            //     ),
            //     const SizedBox(
            //       height: Sizes.spaceXSmall,
            //     ),
            //     Text(
            //       translate(
            //         'network_adding_usage_notice',
            //       ),
            //       style: FontTheme.of(context).body2.primary(),
            //       textAlign: TextAlign.center,
            //     ),
            //     const SizedBox(
            //       height: Sizes.spaceXSmall,
            //     ),
            //     network.networkType == NetworkType.custom
            //         ? Text(
            //             translate(
            //               'custom_network_security_alert',
            //             ),
            //             style: FontTheme.of(context).body1().copyWith(
            //                 color: ColorsTheme.of(context).textCritical),
            //             textAlign: TextAlign.center,
            //           )
            //         : Container()
            //   ],
            // ),
            // const SizedBox(
            //   height: Sizes.spaceXSmall,
            // ),
            PropertyItem(
                title: translate('network_name'),
                value: network.label ?? network.web3RpcHttpUrl),
            PropertyItem(
                title: translate('rpc_url'), value: network.web3RpcHttpUrl),
            PropertyItem(
                title: translate('chain_id'),
                value: network.chainId.toString()),
            PropertyItem(title: translate('symbol'), value: network.symbol),
            network.explorerUrl != null
                ? PropertyItem(
                    title: translate('block_explorer_url'),
                    value: network.explorerUrl!)
                : Container(),
            const SizedBox(
              height: Sizes.spaceXSmall,
            ),
            MxcButton.secondary(
              key: const ValueKey('closeButton'),
              title: translate('close'),
              onTap: () => Navigator.of(context).pop(false),
              size: AxsButtonSize.xl,
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
          ],
        ),
      ),
    ),
  );
}
