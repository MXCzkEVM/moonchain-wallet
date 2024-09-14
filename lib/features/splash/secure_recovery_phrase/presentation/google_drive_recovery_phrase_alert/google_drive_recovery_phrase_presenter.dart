import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'google_drive_recovery_phrase_state.dart';

final googleDriveRecoveryPhraseContainer = PresenterContainer<
    GoogleDriveRecoveryPhrasePresenter,
    GoogleDriveRecoveryPhraseState>(() => GoogleDriveRecoveryPhrasePresenter());

class GoogleDriveRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<GoogleDriveRecoveryPhraseState> {
  GoogleDriveRecoveryPhrasePresenter()
      : super(GoogleDriveRecoveryPhraseState());

  void storeAndProceed() {}

  void saveToGoogleDrive() {}
}
