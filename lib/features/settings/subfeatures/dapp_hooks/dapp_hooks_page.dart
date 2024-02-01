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
    final dappHooksState = ref.watch(state);
    final dappHooksPresenter = ref.read(presenter);

    final frequency = getPeriodicalCallDurationFromInt(
        dappHooksState.dAppHooksData!.duration);

    final isMXCChains = Config.isMxcChains(dappHooksState.network!.chainId);
    final dappHooksServiceServiceEnabled =
        dappHooksState.dAppHooksData!.enabled;

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
          value: dappHooksState.dAppHooksData!.enabled,
          onChanged: dappHooksPresenter.enableDAppHooks,
          enabled: true,
          textTrailingWidget: const DAppHooksInformation(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MXCDropDown(
          key: const Key('dappHooksFrequencyDropDown'),
          onTap: dappHooksPresenter.showDAppHooksFrequency,
          selectedItem: frequency.toStringFormatted(),
          enabled:
              isSettingsChangeEnabled && dappHooksState.dAppHooksData!.enabled,
        ),
        const SizedBox(height: Sizes.spaceNormal),
        SwitchRowItem(
          key: const Key('wifiHookSwitch'),
          title: translate('wifi_hooks'),
          value: dappHooksState.dAppHooksData!.wifiHooks.enabled,
          onChanged: dappHooksPresenter.enableWifiHooks,
          enabled: isSettingsChangeEnabled,
        ),
        const SizedBox(height: Sizes.spaceNormal),
        SwitchRowItem(
          key: const Key('locationServiceSwitch'),
          title: translate('location_service'),
          value: dappHooksState.locationServiceEnabled,
          onChanged: dappHooksPresenter.changeLocationServiceState,
          enabled: isSettingsChangeEnabled,
          paddings: const EdgeInsets.symmetric(horizontal: Sizes.spaceXSmall),
          switchActiveColor: ColorsTheme.of(context).btnBgBlue,
        ),
        const SizedBox(height: Sizes.spaceNormal),
        // SwitchRowItem(
        //   key: const Key('minerHookSwitch'),
        //   title: translate('miner_hooks'),
        //   value: dappHooksState.dAppHooksData!.minerHooks.enabled,
        //   onChanged: dappHooksPresenter.enableMinerHooks,
        //   enabled: isSettingsChangeEnabled,
        // ),
        // const SizedBox(height: Sizes.spaceNormal),
        // MXCDropDown(
        //   key: const Key('minerHooksTimingDropDown'),
        //   onTap: dappHooksPresenter.showTimePickerDialog,
        //   selectedItem:
        //       dappHooksState.dAppHooksData!.minerHooks.time.format(context),
        //   enabled: true,
        // ),
      ],
    );
  }
}
