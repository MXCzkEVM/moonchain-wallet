import 'dart:async';

import 'package:app_links/app_links.dart';

class MoonchainAppLinks {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? linkSubscription;
  

  Future<Uri?> initAppLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();

    // Handle link when app is in warm state (front or background)
    linkSubscription = _appLinks.uriLinkStream.listen((event) { });
    return appLink;
  }


  void cancelAppLinks() {
    linkSubscription?.cancel();
  }
}
