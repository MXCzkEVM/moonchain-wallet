import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'passcode_change_enter_current_page_presenter.dart';
import 'passcode_change_enter_current_page_state.dart';

class PasscodeChangeEnterCurrentPage extends PasscodeBasePage {
  const PasscodeChangeEnterCurrentPage(
      {Key? key, this.change = false, this.dismissedDest})
      : super(key: key);

  final bool change;
  final String? dismissedDest;

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'change_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'enter_current_passcode');

  @override
  String? dismissedPage() => dismissedDest;

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeChangeEnterCurrentPageContainer.actions;

  @override
  ProviderBase<PasscodeChangeEnterCurrentPageState> get state =>
      passcodeChangeEnterCurrentPageContainer.state;

  @override
  Widget buildErrorMessage(BuildContext context, WidgetRef ref) => SizedBox(
        height: 90,
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
                const SizedBox(height: 6),
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
