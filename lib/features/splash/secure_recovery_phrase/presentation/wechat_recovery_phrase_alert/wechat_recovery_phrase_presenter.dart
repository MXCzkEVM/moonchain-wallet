import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';

import 'wechat_recovery_phrase_state.dart';

final wechatRecoveryPhraseContainer = PresenterContainer<
    WechatRecoveryPhrasePresenter,
    WechatRecoveryPhrasetState>(() => WechatRecoveryPhrasePresenter());

class WechatRecoveryPhrasePresenter
    extends RecoveryPhraseBasePresenter<WechatRecoveryPhrasetState> {
  WechatRecoveryPhrasePresenter() : super(WechatRecoveryPhrasetState());
}
