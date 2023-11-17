import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

final route = _RouteBuilder();

String extractNameForRoute(page) => page.runtimeType.toString();

class _RouteBuilder {
  PageRoute call<T extends Widget>(
    T page, {
    String? featureName,
    bool maintainState = true,
    bool fromBottomToTop = false,
    bool showAnimation = true,
  }) {
    final routeName = extractNameForRoute(page);

    final routeSettings = RouteSettings(name: routeName);

    if (featureName != null) {
      if (fromBottomToTop) {
        return FeatureBottomToTopPageRoute(
          featureName: featureName,
          maintainState: maintainState,
          builder: (_) => page,
          settings: routeSettings,
          skipAnimation: !showAnimation,
        );
      } else {
        return FeaturePageRoute(
          featureName: featureName,
          maintainState: maintainState,
          builder: (_) => page,
          settings: routeSettings,
          skipAnimation: !showAnimation,
        );
      }
    } else {
      if (fromBottomToTop) {
        return BottomToTopPageRoute(
          maintainState: maintainState,
          builder: (_) => page,
          settings: routeSettings,
          skipAnimation: !showAnimation,
        );
      } else {
        return CupertinoPageRoute(
          maintainState: maintainState,
          builder: (_) => page,
          settings: routeSettings,
        );
      }
    }
  }

  PageRoute featureDialog<T extends Widget>(T widget,
      {bool maintainState = true, bool canPopThisPage = true}) {
    final routeName = extractNameForRoute(widget);

    final routeSettings = RouteSettings(name: routeName);

    return BottomFlowDialogRoute(
        maintainState: maintainState,
        settings: routeSettings,
        builder: (ctx) => widget,
        canPopThisPage: canPopThisPage);
  }

  PageRoute featureDialogPage<T extends Widget>(
    T widget, {
    bool maintainState = true,
    bool skipAnimation = false,
  }) {
    final routeName = extractNameForRoute(widget);

    final routeSettings = RouteSettings(name: routeName);
    return BottomFlowDialogPageRoute(
        builder: (ctx) => widget,
        maintainState: maintainState,
        skipAnimation: skipAnimation,
        settings: routeSettings);
  }
}

class FeaturePageRoute<T> extends CupertinoPageRoute<T> {
  FeaturePageRoute({
    required this.featureName,
    required WidgetBuilder builder,
    bool maintainState = true,
    RouteSettings? settings,
    this.skipAnimation = false,
  }) : super(
          builder: builder,
          maintainState: maintainState,
          settings: settings,
        );

  final String featureName;

  final bool skipAnimation;

  T? _featureResult;

  @override
  Duration get transitionDuration =>
      skipAnimation ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => super.transitionDuration;

  @override
  T? get currentResult => _featureResult;
}

class FeatureBottomToTopPageRoute<T> extends BottomToTopPageRoute<T> {
  FeatureBottomToTopPageRoute({
    required this.featureName,
    required WidgetBuilder builder,
    bool maintainState = true,
    RouteSettings? settings,
    bool skipAnimation = false,
  }) : super(
          builder: builder,
          maintainState: maintainState,
          settings: settings,
          skipAnimation: skipAnimation,
        );

  final String featureName;

  T? _featureResult;

  @override
  T? get currentResult => _featureResult;
}

class BottomToTopPageRoute<T> extends MaterialPageRoute<T> {
  BottomToTopPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    this.skipAnimation = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
        );

  final bool skipAnimation;

  @override
  Duration get transitionDuration =>
      skipAnimation ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => super.transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      )),
      child: child,
    );
  }
}

extension NavigatorExtensions on NavigatorState {
  Future<void> pushFeatureEnding(Route route, {required Object? result}) {
    popFeature(result);
    return push(route);
  }

  void popFeature([Object? value]) {
    final bottomFlowDialog = BottomFlowDialog.maybeOf(context);
    if (bottomFlowDialog != null) {
      bottomFlowDialog.close(value);
      return;
    }
    popUntil((route) =>
        route is FeaturePageRoute || route is FeatureBottomToTopPageRoute);
    pop(value);
  }

  void popOrCloseDialog([Object? value]) {
    final navigator = this;
    if (navigator.canPop()) {
      navigator.pop(value);
      return;
    }
    final bottomFlowDialog = BottomFlowDialog.maybeOf(context);
    if (bottomFlowDialog != null) {
      bottomFlowDialog.close(value);
    }
  }

  Route get currentRoute {
    Route? res;
    popUntil((route) {
      res = route;
      return true;
    });
    return res!;
  }

  Future<T?> replaceAll<T>(Route<T> route) {
    return pushAndRemoveUntil(route, (page) {
      return false;
    });
  }

  Future<T?> replaceSheet<T>(Route<T> route) {
    final bottomFlowDialog = BottomFlowDialog.of(context);
    return bottomFlowDialog.parentNavigator.pushReplacement(route);
  }

  NavigatorState get root => Navigator.of(context, rootNavigator: true);
}

extension NavigatorKeyExtensions on GlobalKey<NavigatorState> {
  /// Returns [currentState] if available, otherwise waits for the first frame
  FutureOr<NavigatorState> stateOrWait() {
    if (currentState != null) return Future.value(currentState!);
    final completer = Completer<NavigatorState>();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => completer.complete(currentState!),
    );
    return completer.future;
  }
}
