import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/security/presentation/passcode_change/passcode_change_enter_current_page/passcode_change_enter_current_page.dart';
import 'package:datadashwallet/features/security/presentation/passcode_change/passcode_change_enter_new_page/passcode_change_enter_new_page.dart';
import 'package:datadashwallet/features/security/presentation/passcode_require/passcode_require_presenter.dart';
import 'package:datadashwallet/features/security/presentation/passcode_require/wrapper/passcode_require_wrapper_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'security_settings_presenter.dart';
import 'security_settings_state.dart';

class SecuritySettingsPage extends HookConsumerWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  ProviderBase<SecuritySettingsPresenter> get presenter =>
      securitySettingsContainer.actions;

  @override
  ProviderBase<SecuritySettingsState> get state =>
      securitySettingsContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        title: Text(
          translate('security'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        Text(
          translate('change_passcode'),
          style: FontTheme.of(context).body2(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        Text(
          translate('change_passcode_note'),
          style: FontTheme.of(context).subtitle1.secondary(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MxcButton.secondary(
          key: const ValueKey('changePasscodeButton'),
          title: translate('change_passcode'),
          size: MxcButtonSize.xl,
          onTap: () => Navigator.of(context).push(
            route.featureDialog(const PasscodeChangeEnterCurrentPage()),
          ),
        ),
        const SizedBox(height: Sizes.space4XLarge),
        Text(
          translate('clear_browser_cache_note'),
          style: FontTheme.of(context).body2(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MxcButton.secondary(
          key: const ValueKey('clearBrowserCacheButton'),
          title: translate('clear_browser_cache'),
          size: MxcButtonSize.xl,
          onTap: () => ref.read(presenter).clearBrowserCache(),
        ),
        const SizedBox(height: Sizes.space4XLarge),
        Text(
          translate('delete_wallet_note'),
          style: FontTheme.of(context).body2(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MxcButton.primaryWarning(
          key: const ValueKey('deleteWalletButton'),
          title: translate('delete_wallet'),
          size: MxcButtonSize.xl,
          onTap: () => ref.read(presenter).deleteWallet(),
        ),
        const SizedBox(height: Sizes.space4XLarge),
        Text(
          translate('export_wallet_note'),
          style: FontTheme.of(context).body2(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MxcButton.secondary(
          key: const ValueKey('exportWalletButton'),
          title: translate('export_wallet'),
          size: MxcButtonSize.xl,
          onTap: () {},
        ),
        const SizedBox(height: Sizes.space4XLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('face_id'),
              style: FontTheme.of(context).body2(),
            ),
            CupertinoSwitch(
              value: true,
              onChanged: (value) {},
            ),
          ],
        )
      ],
    );
  }
}
