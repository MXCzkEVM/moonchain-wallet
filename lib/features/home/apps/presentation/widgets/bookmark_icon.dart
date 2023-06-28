import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BookmarkIcon extends StatelessWidget {
  const BookmarkIcon({
    super.key,
    required this.title,
    required this.url,
    this.onTap,
    this.isEditMode = false,
    this.onRemoveTap,
  });

  final String title;
  final String url;
  final VoidCallback? onTap;
  final bool isEditMode;
  final VoidCallback? onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
              color: ColorsTheme.of(context).box,
            ),
            child: Text(
              title,
              style: FontTheme.of(context).subtitle2().copyWith(
                    color: ColorsTheme.of(context).secondaryText,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isEditMode)
            Positioned(
              top: 3,
              left: 2,
              child: GestureDetector(
                onTap: onRemoveTap,
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
