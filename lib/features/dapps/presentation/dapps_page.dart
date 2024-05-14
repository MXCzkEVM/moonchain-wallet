import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'dapps_presenter.dart';
import 'dapps_state.dart';
import 'responsive_layout/responsive_layout.dart';
import 'widgets/edit_mode_status_bar.dart';

class DAppsPage extends HookConsumerWidget {
  const DAppsPage({Key? key}) : super(key: key);

  @override
  ProviderBase<DAppsPagePresenter> get presenter =>
      appsPagePageContainer.actions;

  @override
  ProviderBase<DAppsState> get state => appsPagePageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dappsPresenter = ref.watch(presenter);
    return MxcPage(
      layout: LayoutType.column,
      useContentPadding: false,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      backgroundColor: ColorsTheme.of(context).screenBackground,
      presenter: ref.watch(presenter),
      appBar: Column(
        children: [
          if (ref.watch(state).isEditMode) ...[
            EditAppsModeStatusBar(
              onAdd: dappsPresenter.addBookmark,
              onDone: dappsPresenter.changeEditMode,
            ),
          ],
          AppNavBar(
            leading: IconButton(
              key: const ValueKey('settingsButton'),
              icon: const Icon(MxcIcons.settings),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context).push(
                  route(
                    const SettingsPage(),
                  ),
                );
              },
              color: ColorsTheme.of(context).iconPrimary,
            ),
            action: IconButton(
              key: const ValueKey('walletButton'),
              icon: const Icon(MxcIcons.wallet),
              iconSize: 32,
              onPressed: () => Navigator.of(context).replaceAll(
                route(const WalletPage()),
              ),
              color: ColorsTheme.of(context).iconPrimary,
            ),
          ),
        ],
      ),
      children: const [
        Expanded(
          child: Center(
            child: ResponsiveLayout(),
          ),
        )
      ],
    );
  }
}
