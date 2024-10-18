import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

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