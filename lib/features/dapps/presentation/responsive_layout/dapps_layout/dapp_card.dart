import 'dart:math';

import 'package:moonchain_wallet/common/components/context_menu_extended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../dapps_presenter.dart';
import 'build_card.dart';
import 'context_menu_actions.dart';
import 'shatter_widget.dart';
import 'card_item.dart';

class DAppCard extends HookConsumerWidget {
  final Dapp dapp;
  final int index;
  final double width;
  final int mainAxisCount;
  const DAppCard({
    super.key,
    required this.index,
    required this.width,
    required this.dapp,
    required this.mainAxisCount,
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

    final isMobile = mainAxisCount == CardMainAxisCount.mobile;
    final imageRatioFactor = (isMobile ? 0.2 : 0.1);
    final animatedSize = (isMobile ? 0.25 : 0.15);
    final sizeLimit = (imageRatioFactor / animatedSize);

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
        return ReorderableItemView(
          key: Key(dappUrl),
          index: index,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: animationController.value *
                    (pi / 8), // Adjust the range of rotation
                child: child,
              );
            },
            child: SizedBox.expand(
                child: buildCard(
                    context, dapp, mainAxisCount, onTap, isEditMode, width,
                    shatter: shatter, actions: actions)),
          ),
        );
      }
      return CupertinoContextMenuExtended.builder(
        builder: (context, animation) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / (mainAxisCount),
            height: MediaQuery.of(context).size.width / (mainAxisCount),
            child: buildCard(
              context,
              dapp,
              mainAxisCount,
              onTap,
              isEditMode,
              width,
              ratioFactor: animation.value < sizeLimit
                  ? null
                  : (animatedSize * animation.value),
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
