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
  int mainAxisCount,
  VoidCallback? onTap,
  bool isEditMode,
  // double width,
  {
  double? ratioFactor,
  DAppsPagePresenter? actions,
  void Function()? shatter,
  bool animated = false,
}) {
  final isMobile = mainAxisCount == CardMainAxisCount.mobile;
  final imageRatioFactor = (isMobile ? 0.2 : 0.1);
  String? image =
      'packages/mxc_logic/assets/cache/MEP-1759-DApp-store/mxc_dapps_thumbnails/test.png';
  // if (dapp is Bookmark) {
  //   if ((dapp).image != null) {
  //     image = (dapp).image!;
  //   } else {
  //     actions!.updateBookmarkFavIcon(dapp);
  //   }
  // } else {
  //   image = dapp.reviewApi?.icon;
  // }
  final name = dapp is Bookmark ? (dapp).title : dapp.app?.name;
  final url = dapp is Bookmark ? (dapp).url : dapp.app?.url;
  final info = dapp is Bookmark ? (dapp).description : dapp.app?.description;
  // final imageSize = width * (ratioFactor ?? imageRatioFactor);
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
      color: Colors.red,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                image == null
                    ? Icon(
                        Icons.image_not_supported_rounded,
                        color: ColorsTheme.of(context).textPrimary,
                      )
                    : image.contains(
                              'https',
                            ) ||
                            image.contains(
                              'http',
                            )
                        ? image.contains(
                            'svg',
                          )
                            ? SvgPicture.network(
                                image,
                              )
                            : CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Column(
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: ColorsTheme.of(context)
                                            .textError,
                                      ),
                                    ],
                                  );
                                },
                              )
                        : image.contains(
                            'svg',
                          )
                            ? SvgPicture.asset(
                                image,
                              )
                            : Image.asset(image),
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
                      .caption1
                      .primary()
                      .copyWith(fontWeight: FontWeight.w700),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  info ?? '',
                  style: FontTheme.of(context)
                      .caption2
                      .primary()
                      .copyWith(fontWeight: FontWeight.w500),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
