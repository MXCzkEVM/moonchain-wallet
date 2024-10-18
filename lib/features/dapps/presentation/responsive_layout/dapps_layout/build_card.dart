import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../dapps_presenter.dart';
import 'card_item.dart';

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

class DappIcon extends StatelessWidget {
  final String? image;
  const DappIcon({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Icon(
        Icons.image_not_supported_rounded,
        color: ColorsTheme.of(context).textPrimary,
      );
    }

    final isNetworkImage = image!.contains(
          'https',
        ) ||
        image!.contains(
          'http',
        );

    if (isNetworkImage) {
      if (image!.contains('svg')) {
        return SvgPicture.network(
          image!,
          fit: BoxFit.fill,
        );
      } else {
        return CachedNetworkImage(
          imageUrl: image!,
          fit: BoxFit.fill,
          errorWidget: (context, url, error) {
            return Column(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: ColorsTheme.of(context).textError,
                ),
              ],
            );
          },
        );
      }
    } else {
      if (image!.contains('svg')) {
        return SvgPicture.asset(
          image!,
          fit: BoxFit.fill,
        );
      } else {
        return Image.asset(
          image!,
          fit: BoxFit.fill,
        );
      }
    }
  }
}

Widget buildDappIcon(BuildContext context, String? image, bool isBookmark) {
  return isBookmark
      ? Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
          decoration: const BoxDecoration(
            color: Color(0XFF040404),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: DappIcon(image: image),
        )
      : DappIcon(image: image);
}
