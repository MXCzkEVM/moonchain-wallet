import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class ChainDetails extends StatelessWidget {
  const ChainDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future<bool?> showChainDialog(
  BuildContext context, {
  required Network network,
  required void Function(Network chainId) onTap,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: Sizes.spaceNormal,
                end: Sizes.spaceNormal,
                bottom: Sizes.space2XLarge),
            child: MxcAppBarEvenly.title(
              titleText: network.label,
              action: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Text(
                    FlutterI18n.translate(context, 'done'),
                    style: FontTheme.of(context).body1.primary(),
                  ),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
          ),
          PropertyItem(title: translate('network_name'), value: network.label),
          PropertyItem(
              title: translate('rpc_url'), value: network.web3RpcHttpUrl),
          PropertyItem(
              title: translate('chain_id'), value: network.chainId.toString()),
          PropertyItem(title: translate('symbol'), value: network.symbol),
          const SizedBox(
            height: Sizes.space2XLarge,
          ),
          network.enabled == false
              ? MxcButton.secondary(
                  key: const ValueKey('setAsDefaultButton'),
                  title: translate('set_as_default'),
                  onTap: () {
                    onTap(network);
                  },
                  size: MxcButtonSize.xl,
                )
              : Container()
        ],
      ),
    ),
  );
}

class PropertyItem extends StatelessWidget {
  final String title;
  final String value;

  const PropertyItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Sizes.spaceXSmall),
      padding: const EdgeInsets.symmetric(
          vertical: Sizes.spaceXSmall, horizontal: Sizes.spaceXLarge),
      child: Column(children: [
        Text(
          title,
          style: FontTheme.of(context).body2.secondary(),
        ),
        const SizedBox(
          width: Sizes.space2XSmall,
        ),
        Text(
          value,
          style: FontTheme.of(context).body1.primary(),
        ),
      ]),
    );
  }
}
