import 'dart:async';

import 'package:app_links/app_links.dart';

class MoonchainAppLinks {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? linkSubscription;
  

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      print('getInitialAppLink: $appLink');
      openAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    linkSubscription = _appLinks.uriLinkStream.listen((event) { });
  }

  void openAppLink(Uri uri, ) {
    print('Trying to launch $uri');
    // navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  void cancelAppLinks() {
    linkSubscription?.cancel();
  }
}
