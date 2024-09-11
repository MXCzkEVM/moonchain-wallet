import 'package:moonchain_wallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'passcode_change_enter_new_page_presenter.dart';

class PasscodeChangeEnterNewPage extends PasscodeBasePage {
  const PasscodeChangeEnterNewPage({Key? key, this.dismissedDest})
      : super(key: key);

  final String? dismissedDest;

  @override
  String title(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'change_passcode');

  @override
  String hint(BuildContext context, WidgetRef ref) =>
      FlutterI18n.translate(context, 'change_passcode_hint');

  @override
  String? dismissedPage() => dismissedDest;

  @override
  ProviderBase<PasscodeBasePagePresenter> get presenter =>
      passcodeChangeEnterNewPageContainer.actions;

  @override
  ProviderBase<PasscodeBasePageState> get state =>
      passcodeChangeEnterNewPageContainer.state;

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) {
    return MxcAppBar.back(text: title(context, ref));
  }
}
