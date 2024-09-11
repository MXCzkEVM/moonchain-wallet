import 'dart:async';

import 'package:moonchain_wallet/common/common.dart';
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
    showSnackBar(context: context, content: message);
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
