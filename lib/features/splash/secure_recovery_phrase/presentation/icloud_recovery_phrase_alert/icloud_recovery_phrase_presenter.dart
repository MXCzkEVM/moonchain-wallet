import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';


final iCloudRecoveryPhraseContainer = PresenterContainer<
    ICloudRecoveryPhrasePresenter,
    ICloudRecoveryPhraseState>(() => ICloudRecoveryPhrasePresenter());

class ICloudRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<ICloudRecoveryPhraseState> {
  ICloudRecoveryPhrasePresenter() : super(ICloudRecoveryPhraseState());
}
