import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'icloud_recovery_phrase_state.dart';

final iCloudRecoveryPhraseContainer = PresenterContainer<
    ICloudRecoveryPhrasePresenter,
    ICloudRecoveryPhraseState>(() => ICloudRecoveryPhrasePresenter());

class ICloudRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<ICloudRecoveryPhraseState> {
  ICloudRecoveryPhrasePresenter()
      : super(ICloudRecoveryPhraseState());

  void storeAndProceed() {}

  void saveToGoogleDrive() {}
}
