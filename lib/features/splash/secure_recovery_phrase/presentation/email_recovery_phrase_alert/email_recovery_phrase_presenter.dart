import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'email_recovery_phrase_state.dart';

final emailRecoveryPhraseContainer =
    PresenterContainer<EmailRecoveryPhrasePresenter, EmailRecoveryPhrasetState>(
        () => EmailRecoveryPhrasePresenter());

class EmailRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<EmailRecoveryPhrasetState> {
  EmailRecoveryPhrasePresenter() : super(EmailRecoveryPhrasetState());
}
