import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../dapps_presenter.dart';
import 'dapps_layout.dart';

Widget buildCard(
  BuildContext context,
  Dapp dapp,
  VoidCallback? onTap,
  bool isEditMode, {
  DAppsPagePresenter? actions,
  void Function()? shatter,
  bool animated = false,
  bool contextMenuAnimation = false,
}) {
  String? image;
  final isBookmark = dapp is Bookmark;
  if (isBookmark) {
    if ((dapp).image != null) {
      image = (dapp).image!;
    } else {
      actions!.updateBookmarkFavIcon(dapp);
    }
  } else {
    image = dapp.reviewApi?.iconV2;
  }
  final name = dapp is Bookmark ? (dapp).title : dapp.app?.name;
  final url = dapp is Bookmark ? (dapp).url : dapp.app?.url;
  final info = dapp is Bookmark ? (dapp).description : dapp.app?.description;
  return GestureDetector(
    onTap: () {
      if (animated) {
        Navigator.pop(context);
        Future.delayed(
          const Duration(milliseconds: 500),
          () => onTap!(),
        );
      } else if (onTap != null) {
        onTap();
      }
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 60 / 64,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  buildDappIcon(context, image, isBookmark),
                  if (isEditMode && dapp is Bookmark)
                    Positioned(
                      top: -6,
                      left: -6,
                      child: GestureDetector(
                        onTap: () =>
                            actions!.removeBookmarkDialog(dapp, shatter!),
                        child: const Icon(
                          Icons.remove_circle_rounded,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!contextMenuAnimation) ...[
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? url ?? '',
                    style: FontTheme.of(context)
                        .subtitle2
                        .primary()
                        .copyWith(fontWeight: FontWeight.w800),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Flexible(
                    child: Text(
                      info ?? '',
                      style: FontTheme.of(context)
                          .caption1
                          .primary()
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    ),
  );
}
