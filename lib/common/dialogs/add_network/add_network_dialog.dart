import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../common.dart';

Future<bool?> showAddNetworkDialog(
  BuildContext context, {
  required Network network,
  required Network? Function(Network network) approveFunction,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: Sizes.spaceNormal,
              end: Sizes.spaceNormal,
              bottom: Sizes.space2XLarge),
          child: MxcAppBarEvenly.title(
            titleText: network.label ?? network.web3RpcHttpUrl,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate(
                'want_to_add_this_network',
              ),
              style: FontTheme.of(context, listen: false)
                  .body2
                  .primary()
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: Sizes.spaceXSmall,
            ),
            Text(
              translate(
                'network_adding_usage_notice',
              ),
              style: FontTheme.of(context, listen: false).body2.primary(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: Sizes.spaceXSmall,
            ),
            network.networkType == NetworkType.custom
                ? Text(
                    translate(
                      'custom_network_security_alert',
                    ),
                    style: FontTheme.of(context, listen: false)
                        .body1()
                        .copyWith(
                            color: ColorsTheme.of(context, listen: false)
                                .textCritical),
                    textAlign: TextAlign.center,
                  )
                : Container()
          ],
        ),
        const SizedBox(
          height: Sizes.spaceXSmall,
        ),
        PropertyItem(
            title: translate('network_name'),
            value: network.label ?? network.web3RpcHttpUrl),
        PropertyItem(
            title: translate('rpc_url'), value: network.web3RpcHttpUrl),
        PropertyItem(
            title: translate('chain_id'), value: network.chainId.toString()),
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
          key: const ValueKey('cancelButton'),
          title: translate('cancel'),
          onTap: () => Navigator.of(context).pop(false),
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
        const SizedBox(
          height: Sizes.spaceNormal,
        ),
        MxcButton.primary(
          key: const ValueKey('approveButton'),
          title: translate('approve'),
          onTap: () {
            final updatedNetwork = approveFunction(network);
            Navigator.of(context).pop(updatedNetwork != null);
          },
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
      ],
    ),
  );
}
