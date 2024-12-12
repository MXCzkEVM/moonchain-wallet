import 'dart:math';

import 'package:moonchain_wallet/common/components/context_menu_extended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import '../../dapps_presenter.dart';
import 'build_card.dart';
import 'context_menu_actions.dart';
import 'shatter_widget.dart';

class DAppCard extends HookConsumerWidget {
  final Dapp dapp;
  final int index;
  const DAppCard({
    super.key,
    required this.index,
    required this.dapp,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final actions = ref.read(appsPagePageContainer.actions);
    final state = ref.read(appsPagePageContainer.state);

    final isEditMode = state.isEditMode;
    final isBookMark = dapp is Bookmark;
    late String dappUrl;
    void Function()? onTap;

    if (isBookMark) {
      dappUrl = (dapp as Bookmark).url;
      onTap = state.isEditMode
          ? null
          : () => actions.openDapp((dapp as Bookmark).url);
    } else {
      dappUrl = dapp.app!.url!;
      onTap = state.isEditMode
          ? null
          : () async {
              await actions.requestPermissions(dapp);
              actions.openDapp(
                dapp.app!.url!,
              );
            };
    }


    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 75),
      lowerBound: -pi / 50,
      upperBound: pi / 50,
    );

    if (isEditMode) {
      animationController.forward();
    } else {
      animationController.stop();
    }

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    Widget getCardItem({void Function()? shatter}) {
      if (isEditMode) {
        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: animationController.value *
                  (pi / 8), 
              child: child,
            );
          },
          child: SizedBox.expand(
              child: buildCard(
                  context, dapp, onTap, isEditMode, 
                  shatter: shatter, actions: actions)),
        );
      }
      return CupertinoContextMenuExtended.builder(
        builder: (context, animation) {
          return SizedBox(
            width: 300,
            height: 140,
            child: buildCard(
              context,
              dapp,
              onTap,
              isEditMode,
              shatter: shatter,
              actions: actions,
              animated: animation.value != 0.0,
            ),
          );
        },
        actions: getContextMenuActions(
          actions,
          context,
          dapp,
          shatter,
        ),
      );
    }

    return isBookMark
        ? ShatteringWidget(
            builder: (shatter) {
              return getCardItem(shatter: shatter);
            },
            onShatterCompleted: () => actions.removeBookmark(dapp as Bookmark))
        : getCardItem();
  }
}
