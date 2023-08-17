import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BookmarkWidget extends StatelessWidget {
  const BookmarkWidget({
    super.key,
    required this.bookmark,
    this.isEditMode = false,
    this.onTap,
    this.onLongPress,
    this.onRemoveTap,
  });

  final Bookmark bookmark;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Bookmark)? onRemoveTap;

  Widget containerWrap({
    required BuildContext context,
    required Bookmark bookmark,
    Widget? child,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        color: bookmark.occupyGrid == 1
            ? ColorsTheme.of(context).cardBackground
            : null,
      ),
      child: child,
    );
  }

  Widget contianerSize(BuildContext context, Bookmark bookmark) {
    if (bookmark.occupyGrid == 8) {
      return containerWrap(
        context: context,
        bookmark: bookmark,
        width: double.infinity,
        child: bookmark.image != null
            ? Image(image: AssetImage(bookmark.image!))
            : const SizedBox(),
      );
    } else if (bookmark.occupyGrid == 4) {
      double screenWidth = MediaQuery.of(context).size.width;
      double maxWidth = screenWidth > 600 ? 600 : screenWidth;

      return containerWrap(
        context: context,
        bookmark: bookmark,
        width: maxWidth / 2 - 24,
        child: bookmark.image != null
            ? Image(image: AssetImage(bookmark.image!))
            : const SizedBox(),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: containerWrap(
          context: context,
          bookmark: bookmark,
          width: 60,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              bookmark.title,
              style: FontTheme.of(context).subtitle2().copyWith(
                    color: ColorsTheme.of(context).textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          contianerSize(context, bookmark),
          if (isEditMode && bookmark.editable)
            Positioned(
              top: 3,
              left: 2,
              child: InkWell(
                onTap:
                    onRemoveTap != null ? () => onRemoveTap!(bookmark) : null,
                child: const Icon(
                  Icons.remove_circle_rounded,
                  // color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
