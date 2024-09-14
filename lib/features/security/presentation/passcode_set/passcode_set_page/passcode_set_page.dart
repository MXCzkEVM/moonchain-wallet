import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'passcode_set_page_presenter.dart';

class PasscodeSetPage extends PasscodeBasePage {
  const PasscodeSetPage({
    Key? key,
  }) : super(key: key);

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'set_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'set_passcode_hint');

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeSetPageContainer.actions;

  @override
  ProviderBase<PasscodeBasePageState> get state =>
      passcodeSetPageContainer.state;
}
