import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moonchain_wallet/app/app.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:mxc_logic/mxc_logic.dart';

class MoonchainAppLinksUseCase extends ReactiveUseCase {
  MoonchainAppLinksUseCase(
    this._authUseCase,
    this._passcodeUseCase,
  ) {
    initializeListeners();
  }

  final AuthUseCase _authUseCase;
  final PasscodeUseCase _passcodeUseCase;

  BuildContext get currentContext => appNavigatorKey.currentContext!;
  NavigatorState? get navigator => appNavigatorKey.currentState;

  AppLinksRouter get _appLinksRouter => AppLinksRouter(navigator);
  late final MoonchainAppLinks _moonchainAppLinks = MoonchainAppLinks();

  late final ValueStream<Stream<dynamic>?> websocketStreamSubscription =
      reactive(null);
  StreamSubscription<dynamic>? websocketCloseStreamSubscription;
  late final ValueStream<Stream<dynamic>> addressStream =
      reactive(const Stream.empty());
  bool isPassCodeScreenShown = true;
  // This is the widget we need to navigate

  Widget? toNavigateWidget;
  Account? account;

  void initializeListeners() {
    _passcodeUseCase.passcodeScreenIsShown.listen((event) {
      print('TEST:isPassCodeScreenShown: $event');
      isPassCodeScreenShown = event;
      checkNavigationFunction();
    });

    _moonchainAppLinks.initAppLinks().then((value) {
      print('TEST:value: $value');
      if (value != null) {
        handleLink(value);
      }
      _moonchainAppLinks.linkSubscription!.onData((data) {
        print('TEST:data: $data');
        handleLink(data);
      });
    });
  }

  handleLink(Uri data) {
    isLoggedInWrapper(() {
      toNavigateWidget = _appLinksRouter.openLink(data);
      checkNavigationFunction();
    });
  }

  void isLoggedInWrapper(Function function) {
    if (_authUseCase.loggedIn) {
      function();
    }
  }

  void checkNavigationFunction() {
    print(
        'TEST:isPassCodeScreenShown: ${(!isPassCodeScreenShown && toNavigateWidget != null)}');
    if (!isPassCodeScreenShown && toNavigateWidget != null) {
      _appLinksRouter.navigateTo(toNavigateWidget!);
      toNavigateWidget = null;
    }
  }

  @override
  Future<void> dispose() async {
    _moonchainAppLinks.cancelAppLinks();
    super.dispose();
  }
}
