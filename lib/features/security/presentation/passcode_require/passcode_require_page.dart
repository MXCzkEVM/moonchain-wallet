import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'passcode_require_presenter.dart';
import 'passcode_require_state.dart';
import 'widgets/show_reset_passcode_dialog.dart';

class PasscodeRequirePage extends PasscodeBasePage {
  const PasscodeRequirePage({Key? key}) : super(key: key);

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeRequirePageContainer.actions;

  @override
  ProviderBase<PasscodeRequiredPageState> get state =>
      passcodeRequirePageContainer.state;

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'unlock_axs_wallet');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'enter_your_passcode');

  @override
  Widget buildErrorMessage(BuildContext context, WidgetRef ref) {
    if (ref.watch(state).errorText != null) {
      return Text(
        ref.watch(state).errorText!,
        textAlign: TextAlign.center,
        style: ref.watch(state).wrongInputCounter > 3
            ? FontTheme.of(context).subtitle2.error()
            : FontTheme.of(context)
                .subtitle2()
                .copyWith(color: ColorsTheme.of(context).textGrey1),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MxcPage(
        layout: LayoutType.column,
        presenter: ref.watch(presenter),
        useSplashBackground: true,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  title(context, ref),
                  style: FontTheme.of(context).h4.textWhite(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  hint(context, ref),
                  style: FontTheme.of(context).body1.textWhite(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Center(
                  child: numbersRow(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          buildErrorMessage(context, ref),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
            child: MxcButton.secondary(
              key: const ValueKey('forgotPasscodeButton'),
              title: FlutterI18n.translate(context, 'forgot_passcode'),
              size: MxcButtonSize.xl,
              onTap: () => showResetPasscodeDialog(context, ref),
            ),
          ),
          const Spacer(),
          numpad(context, ref),
        ],
      ),
    );
  }
}
