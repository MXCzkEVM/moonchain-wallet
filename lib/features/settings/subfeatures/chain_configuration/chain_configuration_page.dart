import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/chain_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class ChainConfigurationPage extends HookConsumerWidget {
  const ChainConfigurationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(chainConfigurationContainer.actions);
    final state = ref.watch(chainConfigurationContainer.state);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: presenter,
      resizeToAvoidBottomInset: true,
      layout: LayoutType.column,
      useContentPadding: false,
      childrenPadding: const EdgeInsets.only(
          top: Sizes.spaceNormal,
          right: Sizes.spaceXLarge,
          left: Sizes.spaceXLarge),
      appBar: AppNavBar(
        title: Text(
          translate('chain_configuration'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        Expanded(
            child: ListView(
          children: [
            Text(
              translate('added_networks'),
              style: FontTheme.of(context).body2.primary(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
              child: Column(
                children: [
                  ...state.networks
                      .map((e) => NetworkItem(
                            network: e,
                            onTap: presenter.setAsDefault,
                          ))
                      .toList()
                ],
              ),
            ),
            MxcButton.secondary(
              key: const ValueKey('addNetworkButton'),
              title: translate('add_network'),
              edgeType: UIConfig.settingsScreensButtonsEdgeType,
              onTap: () {
                Navigator.of(context).push(
                  route.featureDialog(
                    const AddNetworkPage(),
                  ),
                );
              },
              size: MXCWalletButtonSize.xl,
            ),
            const SizedBox(
              height: Sizes.space4XLarge,
            ),
            Text(
              translate('ipfs_gateway'),
              style: FontTheme.of(context).body2.primary(),
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
            MXCDropDown(
              key: const Key('ipfsGateWayDropDown'),
              onTap: () {
                state.ipfsGateWays != null
                    ? showIpfsGateWayDialog(context,
                        ipfsGateWays: state.ipfsGateWays!,
                        onTap: presenter.selectIpfsGateWay,
                        selectedIpfsGateway: state.selectedIpfsGateWay)
                    : null;
              },
              selectedItem: state.selectedIpfsGateWay ?? '',
            ),
          ],
        ))
      ],
    );
  }
}
