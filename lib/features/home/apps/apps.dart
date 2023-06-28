import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'entities/dapp_card.dart';
import 'presentation/open_app/open_app_page.dart';

export 'entities/dapp_card.dart';
export 'presentation/widgets/card_layout/card_layout.dart';
export 'presentation/widgets/card_layout/card_horizontal_layout.dart';
export 'presentation/widgets/card_layout/card_vertical_layout.dart';

export 'presentation/edit_apps/edit_apps.dart';

Future<void> openAppPage(BuildContext context, DAppCard dapp) {
  return Navigator.of(context).replaceAll(
    route.featureDialog(
      maintainState: false,
      OpenAppPage(dapp: dapp),
    ),
  );
}
