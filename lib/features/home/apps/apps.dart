import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'entities/bookmark.dart';
import 'entities/dapp.dart';
import 'subfeatures/open_dapp/open_dapp_page.dart';

export 'entities/dapp.dart';
export 'subfeatures/add_dapp/presentation/add_bookmark.dart';

Future<void> openAppPage(BuildContext context, Bookmark bookmark) {
  return Navigator.of(context).push(
    route.featureDialog(
      maintainState: false,
      OpenAppPage(bookmark: bookmark),
    ),
  );
}
