import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:provider/provider.dart';
import 'package:datadashwallet/core/core.dart';

class MxcErrorHook extends StatefulWidget {
  const MxcErrorHook({
    Key? key,
    required this.errors,
    required this.child,
    this.customErrorHandler,
    this.catchChildrenErrors = false,
  }) : super(key: key);

  final Stream<ErrorViewModel>? errors;
  final bool Function(ErrorViewModel)? customErrorHandler;
  final bool catchChildrenErrors;

  final Widget child;

  static MxcErrorHookState? maybeOf(BuildContext context) {
    try {
      return Provider.of<MxcErrorHookState>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  State<MxcErrorHook> createState() => MxcErrorHookState();
}

class MxcErrorHookState extends State<MxcErrorHook> {
  StreamSubscription? _subscription;
  bool get catchChildrenErrors => widget.catchChildrenErrors;

  @override
  void initState() {
    super.initState();
    _subscription = widget.errors?.listen.call(onError);
  }

  bool onError(ErrorViewModel error) {
    MxcErrorHookState? parent = MxcErrorHook.maybeOf(context);

    while (parent != null) {
      if (parent.catchChildrenErrors) {
        if (parent.onError(error)) {
          return true;
        }
      }
      parent = MxcErrorHook.maybeOf(parent.context);
    }

    if (widget.customErrorHandler != null) {
      return widget.customErrorHandler!(error);
    }

    final errorMessage = error.message;
    if (errorMessage
        .toLowerCase()
        .contains(RegExp(r'socketexception|timed out|reset by peer'))) {
      return true; // don't display anything
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: FontTheme.of(context, listen: false).body1(),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: ColorsTheme.of(context, listen: false).mainRed,
      ),
    );

    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<MxcErrorHookState>.value(
      value: this,
      child: widget.child,
    );
  }
}
