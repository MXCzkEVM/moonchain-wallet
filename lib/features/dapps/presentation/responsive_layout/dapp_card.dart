import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class DappCard extends StatelessWidget {
  const DappCard({
    super.key,
    required this.dapp,
    this.isEditMode = false,
    this.onTap,
    this.onLongPress,
    this.onRemoveTap,
  });

  final Dapp dapp;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Bookmark?)? onRemoveTap;

  Widget cardBox(BuildContext context) {
    final bookmark = dapp is Bookmark ? dapp as Bookmark : null;
    if (bookmark != null) {
      return Container(
        padding: const EdgeInsets.all(2),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          color: ColorsTheme.of(context).cardBackground,
        ),
        child: Text(
          bookmark.title,
          style: FontTheme.of(context).subtitle2().copyWith(
                color: ColorsTheme.of(context).textSecondary,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      final icons = dapp.reviewApi!.icons!;
      final image = icons.islarge != null && icons.islarge!
          ? icons.iconLarge
          : icons.iconSmall;

      return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: image!.contains('https')
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                )
              : Image.asset(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
              child: cardBox(context),
            ),
          ),
          if (isEditMode)
            Positioned(
              top: -2,
              left: -2,
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
    );
  }
}
