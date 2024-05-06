import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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

class NewDAppCard extends HookConsumerWidget {
  final Dapp dapp;
  final int index;
  final double width;
  final bool isEditMode;
  final VoidCallback? onTap;
  final void Function(Bookmark?)? onRemoveTap;
  final int mainAxisCount;
  NewDAppCard({
    super.key,
    required this.index,
    required this.width,
    required this.dapp,
    required this.isEditMode,
    required this.onTap,
    required this.onRemoveTap,
    required this.mainAxisCount,
  });

  Widget cardBox(BuildContext context) {
    // final icons = dapp.reviewApi!.icons!;
    final image = dapp is Bookmark
        ? (dapp as Bookmark).image ?? '${(dapp as Bookmark).url}/favicon.ico'
        : dapp.reviewApi?.icon ?? 'assets/svg/tether_icon.svg';
    final name = dapp is Bookmark ? (dapp as Bookmark).title : dapp.app!.name!;
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
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
                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
                  width: width * 0.3,
                  height: width * 0.3,
                  child: image.contains('https') && dapp is Bookmark
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
                                // Text('Unable to load website icon', style: FontTheme.of(context).caption1.error(),)
                              ],
                            );
                          },
                        )
                      :  image.contains('https')  ? SvgPicture.network(image) : SvgPicture.asset(
                          image,
                        ),
                ),
              ),
              if (isEditMode && onRemoveTap != null)
                Positioned(
                  top: -6,
                  left: -6,
                  child: GestureDetector(
                    onTap: () => onRemoveTap!(dapp as Bookmark),
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

    getBookMarkContextMenuAction() => [
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
                  style: FontTheme.of(context).subtitle1()),
              onPressed: () => popWrapper(actions.changeEditMode, context)),
          CupertinoContextMenuAction(
              trailingIcon: Icons.add_circle_outline_rounded,
              child: Text(FlutterI18n.translate(context, 'add_new_dapp'),
                  style: FontTheme.of(context).subtitle1()),
              onPressed: () => popWrapper(actions.addBookmark, context)),
          CupertinoContextMenuAction(
              isDestructiveAction: true,
              trailingIcon: Icons.remove_circle_outline_rounded,
              onPressed: () => popWrapper(
                  onRemoveTap != null
                      ? () => onRemoveTap!(dapp as Bookmark)
                      : null,
                  context),
              child: Text(FlutterI18n.translate(context, 'remove_dapp'),
                  style: FontTheme.of(context).subtitle1()))
        ];

    final contextMenuActions = onRemoveTap != null
        ? getBookMarkContextMenuAction()
        : getDAppMarkContextMenuAction();

    return isEditMode
        ? ReorderableItemView(
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
              child: SizedBox.expand(child: cardBox(context)),
            ),
          )
        : CupertinoContextMenu.builder(
            builder: (context, animation) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width / mainAxisCount,
                  height: MediaQuery.of(context).size.width / mainAxisCount,
                  child: cardBox(context));
            },
            actions: contextMenuActions);
  }
}

void popWrapper(void Function()? func, BuildContext context) {
  Navigator.pop(context);
  Future.delayed(
    const Duration(milliseconds: 500),
    () => {if (func != null) func()},
  );
}
