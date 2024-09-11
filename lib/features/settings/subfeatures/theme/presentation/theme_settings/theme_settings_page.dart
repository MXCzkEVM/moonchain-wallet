import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'theme_settings_presenter.dart';
import 'theme_settings_state.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  ProviderBase<ThemeSettingsPresenter> get presenter =>
      themeSettingsContainer.actions;

  ProviderBase<ThemeSettingsState> get state => themeSettingsContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final option = ref.watch(state.select((v) => v.option));

    return MxcPage(
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'theme'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        for (final item in ThemeOption.values)
          Column(
            children: [
              InkWell(
                onTap: () => ref.read(presenter).changeThemeOption(item),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FlutterI18n.translate(context, item.name),
                        style: FontTheme.of(context).body2(),
                      ),
                      if (option == item) ...[
                        const Icon(Icons.check_rounded),
                      ] else ...[
                        const SizedBox(height: 24),
                      ]
                    ],
                  ),
                ),
              ),
              if (ThemeOption.system == item)
                Text(
                  FlutterI18n.translate(context, 'system_appearance'),
                  style: FontTheme.of(context).subtitle1.secondary(),
                ),
              const Divider()
            ],
          )
      ],
    );
  }
}
