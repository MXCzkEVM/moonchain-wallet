import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'local_recovery_phrase_state.dart';

final emailRecoveryPhraseContainer =
    PresenterContainer<LocalRecoveryPhrasePresenter, LocalRecoveryPhraseState>(
        () => LocalRecoveryPhrasePresenter());

class LocalRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<LocalRecoveryPhraseState> {
  LocalRecoveryPhrasePresenter() : super(LocalRecoveryPhraseState());
}
