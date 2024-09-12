import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'passcode_set_confirm_page_presenter.dart';

class PasscodeSetConfirmPage extends PasscodeBasePage {
  const PasscodeSetConfirmPage({
    Key? key,
    required this.expectedNumbers,
  }) : super(
          key: key,
        );

  final List<int> expectedNumbers;

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'set_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'set_passcode_hint');

  @override
  String description(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'confirm_passcode_desc');

  @override
  bool get showBackButton => true;

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeSetConfirmPageContainer.actions(expectedNumbers);

  @override
  ProviderBase<PasscodeBasePageState> get state =>
      passcodeSetConfirmPageContainer.state(expectedNumbers);
}
