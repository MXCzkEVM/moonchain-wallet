import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';

import 'subfeatures/open_dapp/open_dapp_page.dart';

export 'subfeatures/add_dapp/presentation/add_bookmark.dart';
export 'subfeatures/open_dapp/open_dapp_page.dart';
export 'presentation/dapps_page.dart';

Future<void> openAppPage(
    BuildContext context, String url, void Function() refreshApp) {
  return Navigator.of(context)
      .push(
        route.featureDialog(
          maintainState: false,
          OpenAppPage(url: url),
        ),
      )
      .then((value) => refreshApp());
}
