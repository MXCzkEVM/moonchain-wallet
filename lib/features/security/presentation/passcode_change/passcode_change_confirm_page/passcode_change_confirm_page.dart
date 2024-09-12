import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'passcode_change_confirm_page_presenter.dart';

class PasscodeChangeConfirmPage extends PasscodeBasePage {
  const PasscodeChangeConfirmPage(
      {Key? key, required this.expectedNumbers, this.dismissedDest})
      : super(key: key);

  final List<int> expectedNumbers;
  final String? dismissedDest;

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'change_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'confirm_new_passcode_desc');

  @override
  String? dismissedPage() => dismissedDest;

  @override
  bool get showBackButton => true;

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeChangeConfirmPageContainer.actions(expectedNumbers);

  @override
  ProviderBase<PasscodeBasePageState> get state =>
      passcodeChangeConfirmPageContainer.state(expectedNumbers);
}
