import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../open_dapp_presenter.dart';

class DragDownPanel extends HookConsumerWidget {
  const DragDownPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  final double maxPanelHeight = 100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openDAppPageContainer.actions);
    final state = ref.watch(openDAppPageContainer.state);

    state.animationController = useAnimationController();

    return AnimatedBuilder(
      animation: state.animationController!,
      child: child,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              // duration: Duration(milliseconds: 100),
              height: maxPanelHeight  * state.animationController!.value,
              // duration: const Duration(seconds: 2),
              width: double.infinity,
              color: Colors.amber,
            ),
            Transform.translate(
              offset: Offset(0.0, maxPanelHeight  *  state.animationController!.value),
              child: child,
            ),
          ],
        );
      },
    );
  }
}
