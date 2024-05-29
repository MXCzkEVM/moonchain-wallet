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
  double width, {
  double? ratioFactor,
  DAppsPagePresenter? actions,
  void Function()? shatter,
  bool animated = false,
}) {
  
  final isMobile = mainAxisCount == CardMainAxisCount.mobile;
  final imageRatioFactor = (isMobile ? 0.2 : 0.1);
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
  final imageSize = width * (ratioFactor ?? imageRatioFactor);
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
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(Sizes.spaceLarge),
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
                  onTap: () =>
                      actions!.removeBookmarkDialog(dapp as Bookmark, shatter!),
                  child: const Icon(
                    Icons.remove_circle_rounded,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(
          height: Sizes.space2XSmall,
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
