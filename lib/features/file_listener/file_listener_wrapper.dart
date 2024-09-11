import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'file_listener_wrapper_presenter.dart';

class FileListenerWrapper extends HookConsumerWidget {
  const FileListenerWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(fileListenerWrapperContainer.actions);

    useOnAppLifecycleStateChange((
      AppLifecycleState? previous,
      AppLifecycleState current,
    ) {
      presenter.checkImportFile(current);
    });

    return MxcContextHook(
      bridge: presenter.bridge,
      child: child,
    );
  }
}
