import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class NewDAppCard extends StatelessWidget {
  final Dapp dapp;
  final int index;
  final double width;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Bookmark?)? onRemoveTap;
  const NewDAppCard(
      {super.key,
      required this.index,
      required this.width,
      required this.dapp,
      required this.isEditMode,
      required this.onTap,
      required this.onLongPress,
      required this.onRemoveTap});

  Widget cardBox(BuildContext context) {
    final icons = dapp.reviewApi!.icons!;
    const image = 'assets/svg/tether_icon.svg';
    final name = dapp.app!.name!;
    return SizedBox.expand(
      child: Column(
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
              if (isEditMode)
                Positioned(
                  top: -6,
                  left: -6,
                  child: InkWell(
                    onTap: onRemoveTap != null
                        ? () => onRemoveTap!(dapp as Bookmark)
                        : null,
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
  ) {
    return ReorderableItemView(
      key: Key(dapp.app!.url!),
      index: index,
      child: GestureDetector(
        onTap: onTap,
        // onLongPress: onLongPress,
        child: cardBox(context),
      ),
    );
  }
}
