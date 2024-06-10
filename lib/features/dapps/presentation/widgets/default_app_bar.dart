import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/presentation/settings_page.dart';
import 'package:datadashwallet/features/wallet/presentation/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';


class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavBar(
      leading: IconButton(
        key: const ValueKey('settingsButton'),
        icon: const Icon(MxcIcons.settings),
        iconSize: Sizes.space2XLarge,
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
        iconSize: Sizes.space2XLarge,
        onPressed: () => Navigator.of(context).replaceAll(
          route(const WalletPage()),
        ),
        color: ColorsTheme.of(context).iconPrimary,
      ),
    );
  }
}
