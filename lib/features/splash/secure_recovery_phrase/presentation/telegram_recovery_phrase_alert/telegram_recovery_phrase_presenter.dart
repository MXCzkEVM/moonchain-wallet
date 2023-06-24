import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'telegram_recovery_phrase_state.dart';

final telegramRecoveryPhraseContainer = PresenterContainer<
    TelegramRecoveryPhrasePresenter,
    TelegramRecoveryPhrasetState>(() => TelegramRecoveryPhrasePresenter());

class TelegramRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<TelegramRecoveryPhrasetState> {
  TelegramRecoveryPhrasePresenter() : super(TelegramRecoveryPhrasetState());
}
