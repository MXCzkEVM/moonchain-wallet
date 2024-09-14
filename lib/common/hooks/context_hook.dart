import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:moonchain_wallet/core/core.dart';

class MxcContextHook extends StatefulWidget {
  const MxcContextHook({
    Key? key,
    required this.bridge,
    required this.child,
  }) : super(key: key);

  final ContextBridge bridge;
  final Widget child;

  @override
  State<MxcContextHook> createState() => _MxcContextHookState();
}

class _MxcContextHookState extends State<MxcContextHook> {
  @override
  void initState() {
    super.initState();
    widget.bridge.register(_contextResolver);
  }

  BuildContext _contextResolver() => context;

  @override
  void dispose() {
    widget.bridge.unregister(_contextResolver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
