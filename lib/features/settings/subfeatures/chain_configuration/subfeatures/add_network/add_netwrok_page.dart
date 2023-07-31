import 'package:datadashwallet/common/common.dart';
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
    return MxcPage.layer(
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      layout: LayoutType.column,
      children: [
        MxcAppBarEvenly.text(
          titleText:
              translate('add_x').replaceFirst('{0}', translate('network')),
          actionText: translate('done'),
          onActionTap: () => BottomFlowDialog.of(context).close(),
          isActionTap: true,
          showCancel: false,
        ),
        Expanded(
          child: ListView(
            children: [
              Text(
                translate('mainnet'),
                style: FontTheme.of(context).body1.secondary(),
              ),
              ...AddNetworkUtils.generateMainnetList(state.networks),
              const SizedBox(
                height: Sizes.spaceNormal,
              ),
              Text(
                translate('testnet'),
                style: FontTheme.of(context).body1.secondary(),
              ),
              ...AddNetworkUtils.generateTestnetList(state.networks),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: MxcButton.primary(
            key: const ValueKey('add_custom_network'),
            title: translate('add_x')
                .replaceFirst('{0}', translate('custom_network')),
            onTap: () {
              BottomFlowDialog.of(context).close();
            },
            size: MxcButtonSize.xxl,
          ),
        )
      ],
    );
  }
}
