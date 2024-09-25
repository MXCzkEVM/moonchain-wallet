import 'package:flutter/material.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/portfolio/presentation/portfolio_page.dart';
import 'package:moonchain_wallet/features/wallet/wallet.dart';

class AppLinksRouter {
  AppLinksRouter(this.navigator);

  NavigatorState? navigator;

  // TODO:
  // CHeck login 
  // What if already in that page
  // Check to push and replace or only push
  // Link : https://www.mxc1usd.com/app/
  // Routes : dapps - wallet - portfolio (wallet sub page) - openDapp - sendCrypto -
  //

  Widget openLink(Uri uri) {
    final page = getPage(uri);
    final params = getParams(uri);

    return getPageWithParams(page, params);
  }

  String getPage(Uri uri) => uri.pathSegments[1];

  Map<String, List<String>>? getParams(Uri uri) =>
      uri.hasQuery ? uri.queryParametersAll : null;

  Future pushTo(Widget page) => navigator!.push(route(page));
  Future pushAndReplaceUntil(Widget page) => navigator!.pushAndRemoveUntil(
        route(page),
        (route) => false,
      );

  Widget getPageWithParams(String page, Map<String, List<String>>? params) {
    // Avoid navigating to a page that is already up
    // bool inPassCodeRequirePage = false;
    // final currentRoute = navigator.currentRoute.settings.name;
    // if ('PasscodeRequirePage' == currentRoute) {
    //   inPassCodeRequirePage = true;
      // We need to manipulate the widget tree
      // Can be app start or later
    // }
    // How to handle this PasscodeRequirePage
    // if (page.toLowerCase() ==
    //     currentRoute?.toLowerCase().replaceFirst('page', '')) {
    //   collectLog('Trying to navigate to $page, But already in that page!');
    //   return;
    // }
    late Widget toPushPage;

    switch ('/$page') {
      case '/':
        toPushPage = const DAppsPage();
        break;
      case '/dapps':
        toPushPage = const DAppsPage();
        break;
      case '/openDapp':
        toPushPage = const DAppsPage();
        break;
      case '/wallet':
        toPushPage = const WalletPage();
        break;
      case '/portfolio':
        toPushPage = const PortfolioPage();
        break;
      default:
        toPushPage = const DAppsPage();
    }

    return toPushPage;
  }

  void navigateTo(Widget toPushPage){
    late Function() navigationFunc;

    if (toPushPage.runtimeType == OpenDAppPage) {
      navigationFunc = () {
        pushTo(toPushPage);
      };
    } else if (toPushPage.runtimeType == PortfolioPage) {
      navigationFunc = () {
        pushAndReplaceUntil(const WalletPage());
        pushTo(toPushPage);
      };
    } else {
      navigationFunc = () {
        pushAndReplaceUntil(toPushPage);
      };
    }

    navigationFunc();
  }
}
