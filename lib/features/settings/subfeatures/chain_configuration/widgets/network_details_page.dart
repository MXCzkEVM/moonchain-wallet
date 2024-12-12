import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/chain_configuration_presenter.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/chain_configuration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class NetworkDetailsPage extends HookConsumerWidget {
  const NetworkDetailsPage({
    super.key,
    required this.network,
  });

  @override
  ProviderBase<ChainConfigurationPresenter> get presenter =>
      chainConfigurationContainer.actions;

  @override
  ProviderBase<ChainConfigurationState> get state =>
      chainConfigurationContainer.state;

  final Network network;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      backgroundColor: ColorsTheme.of(context).backgroundLightGrey,
      upperBackgroundColor: ColorsTheme.of(context).layerSheetBackground,
      children: [
        MxcAppBarEvenly.text(
          titleText: network.label ?? network.web3RpcHttpUrl,
          actionText: translate('done'),
          onActionTap: () => BottomFlowDialog.of(context).close(),
          isActionTap: true,
          showCancel: false,
        ),
        PropertyItem(
            title: translate('network_name'),
            value: network.label ?? network.web3RpcHttpUrl),
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
                edgeType: UIConfig.settingsScreensButtonsEdgeType,
                onTap: () {
                  ref.read(presenter).setAsDefault(network);
                  BottomFlowDialog.of(context).close();
                },
                size: MXCWalletButtonSize.xl,
              )
            : Container()
      ],
    );
  }
}
