import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/subfeatures/add_custom_network/add_custom_network_page.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/subfeatures/add_network/utils/add_network_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_network_presenter.dart';

class AddNetworkPage extends HookConsumerWidget {
  const AddNetworkPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);
    final presenter = ref.read(addNetworkContainer.actions);
    final state = ref.watch(addNetworkContainer.state);
    final mainnetList = AddNetworkUtils.generateMainnetList(state.networks);
    final testnetList = AddNetworkUtils.generateTestnetList(state.networks);
    final customList = AddNetworkUtils.generateCustomList(state.networks);
    return MxcPage.layer(
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.text(
          titleText: translate('add_x')
              .replaceFirst('{0}', translate('network').toLowerCase()),
          actionText: translate('done'),
          onActionTap: () => BottomFlowDialog.of(context).close(),
          isActionTap: true,
          showCancel: false,
        ),
        mainnetList.isNotEmpty
            ? Text(
                '${translate('mainnet')} ${translate('networks').toLowerCase()}',
                style: FontTheme.of(context).body1.secondary(),
              )
            : Container(),
        ...mainnetList,
        const SizedBox(
          height: Sizes.spaceNormal,
        ),
        testnetList.isNotEmpty
            ? Text(
                '${translate('testnet')} ${translate('networks').toLowerCase()}',
                style: FontTheme.of(context).body1.secondary(),
              )
            : Container(),
        ...testnetList,
        const SizedBox(
          height: Sizes.spaceNormal,
        ),
        customList.isNotEmpty
            ? Text(
                '${translate('custom')} ${translate('networks').toLowerCase()}',
                style: FontTheme.of(context).body1.secondary(),
              )
            : Container(),
        ...customList,
        const SizedBox(
          height: Sizes.spaceNormal,
        ),
        MxcButton.secondary(
          key: const ValueKey('add_custom_network'),
          title: translate('add_x')
              .replaceFirst('{0}', translate('custom_network').toLowerCase()),
          onTap: () {
            Navigator.of(context).push(
              route.featureDialog(
                const AddCustomNetworkPage(),
              ),
            );
          },
          size: AxsButtonSize.xl,
        ),
      ],
    );
  }
}
