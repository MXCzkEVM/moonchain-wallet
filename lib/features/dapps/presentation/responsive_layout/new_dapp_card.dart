import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadashwallet/features/dapps/presentation/responsive_layout/card_item.dart';
import 'package:datadashwallet/common/components/context_menu_extended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../dapps_presenter.dart';
import 'shatter_widget.dart';

class NewDAppCard extends HookConsumerWidget {
  final Dapp dapp;
  final int index;
  final double width;
  final bool isEditMode;
  final VoidCallback? onTap;
  final int mainAxisCount;
  const NewDAppCard({
    super.key,
    required this.index,
    required this.width,
    required this.dapp,
    required this.isEditMode,
    required this.onTap,
    required this.mainAxisCount,
  });

  Widget cardBox(
    BuildContext context, {
    double? ratioFactor,
    DAppsPagePresenter? actions,
    void Function()? shatter,
    bool animated = false,
  }) {
    String? image;
    if (dapp is Bookmark) {
      if ((dapp as Bookmark).image != null) {
        image = (dapp as Bookmark).image!;
      } else {
        actions!.updateBookmarkFavIcon(dapp as Bookmark);
      }
    } else {
      image = dapp.reviewApi!.icon!;
    }
    final name = dapp is Bookmark ? (dapp as Bookmark).title : dapp.app!.name!;
    final imageSize = width *
        (ratioFactor ??
            (mainAxisCount == CardMainAxisCount.mobile ? 0.3 : 0.2));
    return GestureDetector(
      onTap: () {
        if (animated) {
          Navigator.pop(context);
          Future.delayed(
            const Duration(milliseconds: 500),
            () => onTap!(),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(Sizes.spaceXLarge),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  gradient: LinearGradient(
                    colors: [
                      ColorsTheme.of(context).textBlack100,
                      ColorsTheme.of(context).iconBlack200,
                    ],
                    begin: AlignmentDirectional.bottomEnd,
                    end: AlignmentDirectional.topStart,
                  ),
                ),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: image == null
                      ? Icon(
                          Icons.image_not_supported_rounded,
                          color: ColorsTheme.of(context).textPrimary,
                        )
                      : image.contains('https') && dapp is Bookmark
                          ? CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return Column(
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: ColorsTheme.of(context).textError,
                                    ),
                                    const SizedBox(
                                      height: Sizes.spaceXSmall,
                                    ),
                                  ],
                                );
                              },
                            )
                          : image.contains('https')
                              ? SvgPicture.network(
                                  image,
                                )
                              : SvgPicture.asset(
                                  image,
                                ),
                ),
              ),
              if (isEditMode && dapp is Bookmark)
                Positioned(
                  top: -6,
                  left: -6,
                  child: GestureDetector(
                    onTap: () => actions!
                        .removeBookmarkDialog(dapp as Bookmark, shatter!),
                    child: const Icon(
                      Icons.remove_circle_rounded,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: Sizes.spaceXSmall,
          ),
          Text(
            name,
            style: FontTheme.of(context)
                .caption1
                .primary()
                .copyWith(fontWeight: FontWeight.w700),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(appsPagePageContainer.state);
    final actions = ref.read(appsPagePageContainer.actions);
    final dapps = state.orderedDapps;
    final dappAbout =
        dapp is Bookmark ? (dapp as Bookmark).title : dapp.app!.description!;
    final dappUrl = dapp is Bookmark ? (dapp as Bookmark).url : dapp.app!.url!;
    final isBookMark = dapp is Bookmark;

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

    List<Widget> getDAppMarkContextMenuAction() => [
          CupertinoContextMenuAction(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FlutterI18n.translate(context, 'about'),
                style: FontTheme.of(context)
                    .caption1
                    .primary()
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                dapp.app!.description!,
                style: FontTheme.of(context).caption1.primary(),
              ),
            ],
          )),
          CupertinoContextMenuAction(
              trailingIcon: Icons.phone_iphone_rounded,
              child: Text(FlutterI18n.translate(context, 'edit_home_screen'),
                  style: FontTheme.of(context).subtitle1()),
              onPressed: () => popWrapper(actions.changeEditMode, context)),
          CupertinoContextMenuAction(
              trailingIcon: Icons.add_circle_outline_rounded,
              child: Text(FlutterI18n.translate(context, 'add_new_dapp'),
                  style: FontTheme.of(context).subtitle1()),
              onPressed: () => popWrapper(actions.addBookmark, context)),
        ];

    getBookMarkContextMenuAction(void Function() shatter) => [
          CupertinoContextMenuAction(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FlutterI18n.translate(context, 'about'),
                style: FontTheme.of(context)
                    .caption1
                    .primary()
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                dappAbout,
                style: FontTheme.of(context).caption1.primary(),
              ),
            ],
          )),
          CupertinoContextMenuAction(
              trailingIcon: Icons.phone_iphone_rounded,
              child: Text(FlutterI18n.translate(context, 'edit_home_screen'),
                  style: FontTheme.of(context).body1()),
              onPressed: () => popWrapper(actions.changeEditMode, context)),
          CupertinoContextMenuAction(
              trailingIcon: Icons.add_circle_outline_rounded,
              child: Text(FlutterI18n.translate(context, 'add_new_dapp'),
                  style: FontTheme.of(context).body1()),
              onPressed: () => popWrapper(actions.addBookmark, context)),
          CupertinoContextMenuAction(
              isDestructiveAction: true,
              trailingIcon: Icons.remove_circle_outline_rounded,
              onPressed: () => popWrapper(() async {
                    actions.removeBookmarkDialog(dapp as Bookmark, shatter);
                  }, context),
              child: Text(FlutterI18n.translate(context, 'remove_dapp'),
                  style: FontTheme.of(context).body1Cl()))
        ];

    final size = (mainAxisCount == CardMainAxisCount.mobile ? 0.5 : 0.3);
    final sizeLimit =
        (mainAxisCount == CardMainAxisCount.mobile ? 0.6000 : 0.6666);

    Widget getCardItem({void Function()? shatter}) {
      final contextMenuActions = dapp is Bookmark?
          ? getBookMarkContextMenuAction(shatter!)
          : getDAppMarkContextMenuAction();
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
                child: cardBox(context, shatter: shatter, actions: actions)),
          ),
        );
      }
      return CupertinoContextMenuExtended.builder(
        builder: (context, animation) {
          return SizedBox(
            width: MediaQuery.of(context).size.width /
                (mainAxisCount - animation.value),
            height: MediaQuery.of(context).size.width /
                (mainAxisCount - animation.value),
            child: cardBox(context,
                ratioFactor: animation.value < sizeLimit
                    ? null
                    : (size * animation.value),
                shatter: shatter,
                actions: actions,
                animated: animation.value != 0.0),
          );
        },
        actions: contextMenuActions,
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

void popWrapper(void Function()? func, BuildContext context) {
  Navigator.pop(context);
  Future.delayed(
    const Duration(milliseconds: 500),
    () => {if (func != null) func()},
  );
}
