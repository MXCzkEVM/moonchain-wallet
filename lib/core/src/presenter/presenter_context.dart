import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'presenter.dart';

typedef ContextProvider = BuildContext Function();

class ContextBridge {
  final List<ContextProvider> _contextProviders = [];

  void register(ContextProvider contextProvider) {
    _contextProviders.add(contextProvider);
  }

  void unregister(ContextProvider contextProvider) {
    _contextProviders.remove(contextProvider);
  }

  BuildContext? get context {
    assert(() {
      if (_contextProviders.isEmpty) {
        log('No contextProviders registered. Presenter must be connected to widget tree using [MxcPage] or [MxcContextHook]');
        return true;
      }
      if (_contextProviders.length != 1) {
        log('Only one contextProvider can be registered when [perform] is used to avoid unexpected behavior');
        return true;
      }
      return true;
    }());
    return _contextProviders.last();
  }
}

typedef NavigatorResolver = NavigatorState? Function();
mixin ContextPresenter<TStore> on Presenter<TStore> {
  final ContextBridge bridge = ContextBridge();

  NavigatorState? get navigator {
    final context = bridge.context;
    if (context == null) return null;
    return Navigator.of(context);
  }

  Locale? get locale {
    final context = bridge.context;
    if (context == null) return null;
    return FlutterI18n.currentLocale(context) ?? const Locale('en', 'US');
  }

  String? translate(String key) {
    final context = bridge.context;
    if (context == null) return null;
    return FlutterI18n.translate(context, key);
  }

  BuildContext? get context => bridge.context;

  bool get contextAvailable => bridge.context != null;
}
