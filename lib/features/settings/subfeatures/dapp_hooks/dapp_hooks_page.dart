import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/widgets/switch_row_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'dapp_hooks_presenter.dart';
import 'dapp_hooks_state.dart';
import 'widgets/dapp_hooks_information_widget.dart';

class DAppHooksPage extends HookConsumerWidget {
  const DAppHooksPage({Key? key}) : super(key: key);

  @override
  ProviderBase<DAppHooksPresenter> get presenter =>
      notificationsContainer.actions;

  @override
  ProviderBase<DAppHooksState> get state => notificationsContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(state);
    final notificationsPresenter = ref.read(presenter);

    final frequency = getPeriodicalCallDurationFromInt(
        notificationsState.dAppHooksData!.duration);

    final isMXCChains = Config.isMxcChains(notificationsState.network!.chainId);
    final dappHooksServiceServiceEnabled =
        notificationsState.dAppHooksData!.enabled;

    final isSettingsChangeEnabled =
        isMXCChains && dappHooksServiceServiceEnabled;

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'dapp_hooks'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        SwitchRowItem(
          title: translate('dapp_hooks'),
          value: notificationsState.dAppHooksData!.enabled,
          onChanged: notificationsPresenter.enableDAppHooks,
          enabled: true,
          textTrailingWidget: const DAppHooksInformation(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MXCDropDown(
          key: const Key('dappHooksFrequencyDropDown'),
          onTap: notificationsPresenter.showDAppHooksFrequency,
          selectedItem: frequency.toStringFormatted(),
          enabled: isSettingsChangeEnabled &&
              notificationsState.dAppHooksData!.enabled,
        ),
        const SizedBox(height: Sizes.spaceNormal),
        SwitchRowItem(
          title: translate('wifi_hooks'),
          value: notificationsState.dAppHooksData!.wifiHooks.enabled,
          onChanged: notificationsPresenter.enableWifiHooks,
          enabled: isSettingsChangeEnabled,
        ),
        const SizedBox(height: Sizes.spaceNormal),
        // SwitchRowItem(
        //   title: translate('miner_hooks'),
        //   value:
        //       notificationsState.dAppHooksData!.lowBalanceLimitEnabled,
        //   onChanged: notificationsPresenter.enableLowBalanceLimit,
        //   enabled: isSettingsChangeEnabled,
        // ),
      ],
    );
  }
}
