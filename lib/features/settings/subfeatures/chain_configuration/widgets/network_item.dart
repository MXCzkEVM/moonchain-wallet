import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/chain_configuration_presenter.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/subfeatures/delete_custom_network/delete_custom_network_page.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/widgets/chain_logo_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import './network_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class NetworkItem extends HookConsumerWidget {
  const NetworkItem({super.key, required this.network, required this.onTap});

  final Network network;
  final void Function(Network network) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(chainConfigurationContainer.actions);
    return InkWell(
      onTap: () {
        if (network.networkType == NetworkType.custom) {
          presenter.selectedNetworkDetails(network);
          Navigator.of(context).push(
            route.featureDialog(
              const DeleteCustomNetworkPage(),
            ),
          );
        } else {
          Navigator.of(context).push(
            route.featureDialog(
              NetworkDetailsPage(network: network),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.spaceNormal),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ChainLogoWidget(logo: network.logo),
          const SizedBox(
            width: Sizes.spaceXLarge,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.label ?? network.web3RpcHttpUrl,
                  style: FontTheme.of(context).body2.primary(),
                  overflow: TextOverflow.ellipsis,
                ),
                network.enabled
                    ? Text(
                        FlutterI18n.translate(context, 'default'),
                        style: FontTheme.of(context).body1().copyWith(
                            color: ColorsTheme.of(context).textWhite100),
                      )
                    : Container(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceNormal),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ColorsTheme.of(context).white400,
            ),
          ),
        ]),
      ),
    );
  }
}
