import 'dart:io';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/security/presentation/passcode_change/passcode_change_enter_current_page/passcode_change_enter_current_page.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/cupertino.dart';
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
          size: AxsButtonSize.xl,
          onTap: () => Navigator.of(context).push(
            route.featureDialog<PasscodeChangeEnterCurrentPage>(
                const PasscodeChangeEnterCurrentPage(
              dismissedDest: 'SecuritySettingsPage',
            )),
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
          size: AxsButtonSize.xl,
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
          size: AxsButtonSize.xl,
          onTap: () => ref.read(presenter).deleteWallet(),
          titleColor: ColorsTheme.of(context).textBlack200,
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
          size: AxsButtonSize.xl,
          onTap: () => Navigator.of(context).push(
            route(const SplashStoragePage(
              settingsFlow: true,
            )),
          ),
        ),
        const SizedBox(height: Sizes.space4XLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Platform.isAndroid
                  ? translate("fingerprint")
                  : translate('face_id'),
              style: FontTheme.of(context).body2(),
            ),
            CupertinoSwitch(
              value: ref.watch(state).biometricEnabled,
              onChanged: (value) => ref.read(presenter).changeBiometric(value),
            ),
          ],
        )
      ],
    );
  }
}
