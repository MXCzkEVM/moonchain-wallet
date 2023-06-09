import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class MxcSuccessHook extends StatefulWidget {
  const MxcSuccessHook({
    Key? key,
    required this.messages,
    required this.child,
  }) : super(key: key);

  final Stream<String> messages;
  final Widget child;

  @override
  State<MxcSuccessHook> createState() => _MxcSuccessHookState();
}

class _MxcSuccessHookState extends State<MxcSuccessHook> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.messages.listen(_onMessage);
  }

  void _onMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: FontTheme.of(context, listen: false).body1(),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: ColorsTheme.of(context, listen: false).mainGreen,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
