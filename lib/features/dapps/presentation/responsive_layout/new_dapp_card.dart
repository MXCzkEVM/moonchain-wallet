import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  const NewDAppCard({
    super.key,
    required this.index,
    required this.width,
    required this.dapp,
    required this.isEditMode,
    required this.onTap,
    required this.onRemoveTap,
  });

  Widget cardBox(BuildContext context) {
    final icons = dapp.reviewApi!.icons!;
    const image = 'assets/svg/tether_icon.svg';
    final name = dapp.app!.name!;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(Sizes.spaceXLarge),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF262626),
                    CupertinoColors.black,
                  ],
                  stops: [
                    0.00,
                    1.00,
                  ],
                  begin: AlignmentDirectional
                      .topStart, // UnitPoint(x: 0.91, y: 0.88)
                  end: AlignmentDirectional
                      .bottomEnd, // UnitPoint(x: 0.11, y: 0.06)
                ),
              ),
              child: image.contains('https')
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    )
                  : SvgPicture.asset(
                      image,
                      height: 28,
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
              onPressed: () =>
                  popWrapper(actions.navigateToAddBookmark, context)),
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
              onPressed: () =>
                  popWrapper(actions.navigateToAddBookmark, context)),
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

    return GestureDetector(
      onTap: onTap,
      child: isEditMode
          ? ReorderableItemView(
              key: Key(dapp.app!.url!),
              index: index,
              child: SizedBox.expand(child: cardBox(context)),
            )
          : CupertinoContextMenu.builder(
              builder: (context, animation) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
                    child: cardBox(context));
                // Container(
                //   alignment: Alignment.bottomCenter,
                //   color: Colors.transparent,
                //   // decoration: BoxDecoration(),
                //   child: cardBox(context),
                // );
              },
              actions: contextMenuActions

              // child: cardBox(context),
              ),
    );
  }

  void popWrapper(void Function()? func, BuildContext context) {
    Navigator.pop(context);
    Future.delayed(
      Duration(milliseconds: 500),
      () => {if (func != null) func()},
    );
    
  }
}
