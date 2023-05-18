import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class MxcLoadingHook extends StatelessWidget {
  const MxcLoadingHook({
    Key? key,
    required this.loadings,
    required this.child,
  }) : super(key: key);

  final Stream<bool> loadings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: loadings,
      builder: (context, snapshot) {
        final isLoading = snapshot.data ?? false;
        return LoadingBarrier(
          isLoading: isLoading,
          child: child,
        );
      },
    );
  }
}
