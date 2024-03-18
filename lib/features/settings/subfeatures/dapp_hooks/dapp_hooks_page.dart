import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'dapp_hooks_presenter.dart';
import 'dapp_hooks_state.dart';

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

    final minerAutoClaimDateTime =
        dappHooksState.dAppHooksData!.minerHooks.time;
    final autoClaimTime =
        '${minerAutoClaimDateTime.hour.toString().padLeft(2, '0')} : ${minerAutoClaimDateTime.minute.toString().padLeft(2, '0')}';

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
        MXCSwitchRowItem(
          title: translate('dapp_hooks'),
          value: dappHooksState.dAppHooksData!.enabled,
          onChanged: dappHooksPresenter.changeDAppHooksEnabled,
          enabled: true,
          textTrailingWidget: MXCInformationButton(texts: [
            TextSpan(
              text: FlutterI18n.translate(context, 'experiencing_issues'),
              style: FontTheme.of(context)
                  .subtitle2()
                  .copyWith(color: ColorsTheme.of(context).chipTextBlack),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text:
                  FlutterI18n.translate(context, 'background_service_solution'),
              style: FontTheme.of(context)
                  .subtitle1()
                  .copyWith(color: ColorsTheme.of(context).chipTextBlack),
            ),
          ]),
          titleStyle: FontTheme.of(context).h6(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MXCDropDown(
          key: const Key('dappHooksFrequencyDropDown'),
          onTap: dappHooksPresenter.showDAppHooksFrequency,
          selectedItem: frequency.toStringFormatted(),
          enabled:
              isSettingsChangeEnabled && dappHooksState.dAppHooksData!.enabled,
        ),
        const SizedBox(height: Sizes.spaceXLarge),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceLarge),
          child: Column(
            children: [
              MXCSwitchRowItem(
                key: const Key('wifiHookSwitch'),
                title: translate('wifi_hexagon_location_hooks'),
                value: dappHooksState.dAppHooksData!.wifiHooks.enabled,
                onChanged: dappHooksPresenter.changeWifiHooksEnabled,
                enabled: isSettingsChangeEnabled,
                textTrailingWidget: MXCInformationButton(texts: [
                  TextSpan(
                    text: FlutterI18n.translate(context, 'experiencing_issues'),
                    style: FontTheme.of(context)
                        .subtitle2()
                        .copyWith(color: ColorsTheme.of(context).chipTextBlack),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text:
                        FlutterI18n.translate(context, 'wifi_hooks_solutions'),
                    style: FontTheme.of(context)
                        .subtitle1()
                        .copyWith(color: ColorsTheme.of(context).chipTextBlack),
                  ),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: Sizes.spaceLarge),
        MXCSwitchRowItem(
          key: const Key('minerHookSwitch'),
          title: translate('miner_hooks'),
          value: dappHooksState.dAppHooksData!.minerHooks.enabled,
          onChanged: dappHooksPresenter.changeMinerHooksEnabled,
          enabled: isMXCChains,
          titleStyle: FontTheme.of(context).h6(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MXCDropDown(
          key: const Key('minerHooksTimingDropDown'),
          onTap: dappHooksPresenter.showTimePickerDialog,
          selectedItem: autoClaimTime,
          enabled:
              isMXCChains && dappHooksState.dAppHooksData!.minerHooks.enabled,
        ),
      ],
    );
  }
}
