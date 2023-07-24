import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'file_listener_wrapper_presenter.dart';

class FileListenerWrapper extends ConsumerWidget {
  const FileListenerWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcContextHook(
      bridge: ref.watch(fileListenerWrapperContainer.actions).bridge,
      child: child,
    );
  }
}
