import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'passcode_require_presenter.dart';
import 'passcode_require_state.dart';

class PasscodeRequirePage extends PasscodeBasePage {
  const PasscodeRequirePage({Key? key}) : super(key: key);

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'enter_current_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'enter_passcode_hint');

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeRequirePageContainer.actions;

  @override
  ProviderBase<PasscodeRequiredPageState> get state =>
      passcodeRequirePageContainer.state;

  @override
  Widget buildErrorMessage(BuildContext context, WidgetRef ref) => SizedBox(
        height: 64,
        width: 280,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ref.watch(state).errorText != null) ...[
              Text(
                ref.watch(state).errorText!,
                textAlign: TextAlign.center,
                style: FontTheme.of(context).subtitle2.error(),
              ),
              if (ref.watch(state).wrongInputCounter == 2) ...[
                Text(
                  FlutterI18n.translate(context, 'app_will_be_locked_alert'),
                  textAlign: TextAlign.center,
                  style: FontTheme.of(context).subtitle1.error(),
                ),
              ],
            ]
          ],
        ),
      );
}
