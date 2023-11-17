import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/entities/setting.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/chain_configuration_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SettingItem extends HookConsumerWidget {
  const SettingItem({super.key, required this.settingData});

  final Setting settingData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chainConfigurationState =
        ref.watch(chainConfigurationContainer.state);
    final isNetworkStatus =
        settingData.title == FlutterI18n.translate(context, 'network_status');
    final selectedNetwork = chainConfigurationState.networks
        .where(
          (element) => element.enabled,
        )
        .toList()[0];
    final show = isNetworkStatus
        ? (selectedNetwork.chainId == Config.mxcMainnetChainId ||
            selectedNetwork.chainId == Config.mxcTestnetChainId)
        : true;

    return show
        ? Container(
            margin: const EdgeInsets.only(top: Sizes.spaceNormal),
            child: InkWell(
              onTap: settingData.onTap ??
                  () => Navigator.of(context).push(route(
                        settingData.page!,
                      )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
                child: Row(
                  children: [
                    Icon(
                      settingData.icon,
                      size: 24,
                      color: ColorsTheme.of(context).iconGrey3,
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Text(
                      settingData.title,
                      style: FontTheme.of(context).body2.primary(),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 16,
                    ),
                    settingData.trailingIcon != null
                        ? Icon(
                            MxcIcons.external_link,
                            size: 24,
                            color: ColorsTheme.of(context).iconPrimary,
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: ColorsTheme.of(context).iconWhite32,
                          )
                  ],
                ),
              ),
            ),
          )
        : Container();
  }
}
