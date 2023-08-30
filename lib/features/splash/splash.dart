import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/mns_process/mns.dart';
import 'package:flutter/material.dart';

import 'security_notice/security_notice_page.dart';

export 'splash_base/splash_base_page.dart';
export 'splash_base/splash_base_state.dart';
export 'splash_base/splash_base_presenter.dart';

export 'create_storage/presentation/create_storage_page.dart';
export 'create_storage/presentation/create_storage_presenter.dart';

export 'setup_wallet/setup_wallet_page.dart';
export 'import_storage/import_storage_page.dart';
export 'import_wallet/import_wallet_page.dart';

Future<void> pushSecurityNoticePage(BuildContext context) {
  return Navigator.of(context).push(
    route(
      const SecurityNoticePage(),
    ),
  );
}

Future<void> pushMNSAnnouncementPage(BuildContext context) {
  return Navigator.of(context).replaceAll(
    route(
      const SplashMNSAnnouncementPage(),
    ),
  );
}
