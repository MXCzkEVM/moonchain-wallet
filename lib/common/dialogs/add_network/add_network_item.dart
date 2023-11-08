import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/subfeatures/add_network/add_network_presenter.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/subfeatures/add_network/widgets/switch_network_dialog.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/widgets/chain_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_network_dialog.dart';

class AddNetworkItem extends HookConsumerWidget {
  final Network network;

  const AddNetworkItem({
    super.key,
    required this.network,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(addNetworkContainer.actions);
    String translate(String text) => FlutterI18n.translate(context, text);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.spaceSmall,
      ),
      child: Row(children: [
        ChainLogoWidget(logo: network.logo),
        const SizedBox(
          width: Sizes.spaceXSmall,
        ),
        Expanded(
          child: Text(
            network.label ?? network.web3RpcHttpUrl,
            style: FontTheme.of(context).body2.primary(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (network.isAdded == true)
          MxcChipButton(
            key: const Key('addedNetworkButton'),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: Sizes.spaceSmall, vertical: Sizes.spaceXSmall),
            onTap: () {},
            title: translate('added'),
            buttonState: ChipButtonStates.disabled,
          )
        else
          MxcChipButton(
            key: const Key('addNetworkButton'),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: Sizes.spaceSmall, vertical: Sizes.spaceXSmall),
            onTap: () async {
              presenter.showAddDialog(network);
            },
            title: translate('add_x').replaceFirst('{0}', ''),
            buttonState: ChipButtonStates.defaultState,
          )
      ]),
    );
  }
}
