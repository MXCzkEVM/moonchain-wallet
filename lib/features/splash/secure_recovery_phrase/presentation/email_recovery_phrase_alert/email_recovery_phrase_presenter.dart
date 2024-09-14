import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';

import 'email_recovery_phrase_state.dart';

final emailRecoveryPhraseContainer =
    PresenterContainer<EmailRecoveryPhrasePresenter, EmailRecoveryPhrasetState>(
        () => EmailRecoveryPhrasePresenter());

class EmailRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<EmailRecoveryPhrasetState> {
  EmailRecoveryPhrasePresenter() : super(EmailRecoveryPhrasetState());

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  @override
  void initState() {
    super.initState();

    fromController.addListener(
      () => toController.text = fromController.text,
    );
  }
}
