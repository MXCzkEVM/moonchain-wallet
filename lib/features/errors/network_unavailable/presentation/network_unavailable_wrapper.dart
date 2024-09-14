import 'package:moonchain_wallet/common/hooks/hooks.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'network_unavailable_wrapper_presenter.dart';

class NetworkUnavailableWrapper extends ConsumerWidget {
  const NetworkUnavailableWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcContextHook(
      bridge:
          ref.watch(networkUnavailableWrapperPresenterContainer.actions).bridge,
      child: child,
    );
  }
}
