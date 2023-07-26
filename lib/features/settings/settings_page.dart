import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/app_nav_bar/app_nav_bar.dart';
import 'package:datadashwallet/features/settings/entities/setting.dart';
import 'package:datadashwallet/features/settings/settings_page_presenter.dart';
import 'package:datadashwallet/features/settings/widgets/account_managment/account_managment_panel.dart';
import 'package:datadashwallet/features/settings/widgets/settings_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'widgets/account_managment/copyable_item.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);
    final state = ref.watch(settingsContainer.state);
    
    return MxcPage(
      presenter: presenter,
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorsTheme.of(context).screenBackground,
      layout: LayoutType.column,
      useContentPadding: false,
      childrenPadding: const EdgeInsets.only(
          top: 25, right: Sizes.spaceXLarge, left: Sizes.spaceXLarge),
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'settings'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        const AccountManagementPanel(),
        ...Setting.fixedSettings(context)
            .map((e) => SettingItem(settingData: e))
            .toList(),
        const SizedBox(
          height: Sizes.space2XLarge,
        ),
        Text(
          '${FlutterI18n.translate(context, 'app_version')}${state.appVersion ?? ''}',
          style: FontTheme.of(context)
              .subtitle1()
              .copyWith(color: ColorsTheme.of(context).textGrey1),
        )
      ],
    );
  }
}
