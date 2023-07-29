import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/chain_configuration_presenter.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/widgets/chians_dialog.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/widgets/ipfs_gate_ways_dialog.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/widgets/network_item.dart';
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
      backgroundColor: ColorsTheme.of(context).screenBackground,
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
              onTap: () {},
              size: MxcButtonSize.xl,
            ),
            const SizedBox(
              height: Sizes.space4XLarge,
            ),
            Text(
              translate('customize_gas_limit'),
              style: FontTheme.of(context).body2.primary(),
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
            MXCDropDown(
              key: const Key('gasLimitChainDropDown'),
              onTap: () {
                showChainsDialog(context,
                    selectedChainId: state.selectedNetwork!.chainId,
                    networks: state.networks,
                    onTap: presenter.selectNetwork);
              },
              selectedItem: state.selectedNetwork == null
                  ? ''
                  : state.selectedNetwork!.label,
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
            Form(
              key: formKey,
              child: MxcTextField(
                key: const Key('gasLimitTextField'),
                controller: presenter.gasLimitController,
                width: double.maxFinite,
                hint: translate('gas_limit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final res = Validation.notEmpty(
                      context,
                      value,
                      translate('x_not_empty')
                          .replaceFirst('{0}', translate('gas_limit')));
                  if (res != null) return res;

                  return Validation.isNumeric(context, value!);
                },
                onChanged: (value) {
                  if (!formKey.currentState!.validate()) return;
                  presenter.updateGasLimit(value);
                },
              ),
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
                showIpfsGateWayDialog(context,
                    ipfsGateWays: state.ipfsGateWays,
                    onTap: presenter.selectIpfsGateWay,
                    selectedIpfsGateway: state.selectedIpfsGateWay);
              },
              selectedItem: state.selectedIpfsGateWay ?? '',
            ),
          ],
        ))
      ],
    );
  }
}
