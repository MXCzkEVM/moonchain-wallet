import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'presentation/security_notice/security_notice_page.dart';

export 'presentation/recovery_phrase_base/recovery_phrase_base_page.dart';
export 'presentation/recovery_phrase_base/recovery_phrase_base_presenter.dart';
export 'presentation/recovery_phrase_base/recovery_phrase_base_state.dart';

export 'presentation/telegram_recovery_phrase_alert/telegram_recovery_phrase_page.dart';
export 'presentation/wechat_recovery_phrase_alert/wechat_recovery_phrase_page.dart';
export 'presentation/email_recovery_phrase_alert/email_recovery_phrase_page.dart';
// export 'presentation/security_notice/security_notice_page.dart';

export 'presentation/widgets/scale_animation.dart';

Future<void> pushSecurityNoticePage(BuildContext context, String phrases) {
  return Navigator.of(context).push(
    route(
      SecurityNoticePage(
        phrases: phrases,
      ),
    ),
  );
}
