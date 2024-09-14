import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/portfolio/presentation/portfolio_page_presenter.dart';
import 'package:moonchain_wallet/features/portfolio/presentation/portfolio_page_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/main.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum NFTItemType { domain, hexagon, networkImage, localImage, withoutImage }

NFTItemType getNFTItemType(String? nftData) {
  final pattern = RegExp(r'^\w+\.\w+$');
  if (nftData == null) {
    return NFTItemType.withoutImage;
  } else if (nftData.startsWith('assets')) {
    return NFTItemType.localImage;
  } else if (pattern.hasMatch(nftData)) {
    return NFTItemType.domain;
  } else if (nftData.startsWith('#')) {
    return NFTItemType.hexagon;
  } else {
    return NFTItemType.networkImage;
  }
}

Widget getNFTWidget(PortfolioState state, BuildContext context,
    NFTItemType nftItemType, String? nftData) {
  Widget imageLoadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget imageErrorBuilder(
          BuildContext context, Object error, StackTrace? stackTrace) =>
      Text(
        error.toString(),
      );

  switch (nftItemType) {
    case NFTItemType.domain:
      return Container(
        decoration: BoxDecoration(
            color: ColorsTheme.of(context).layerSheetBackground,
            borderRadius: UIConfig.defaultBorderRadiusAll),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Center(
            child: Text(
              nftData!,
              style: FontTheme.of(context).body1.textWhite(),
            ),
          ),
        ),
      );
    case NFTItemType.hexagon:
      return FittedBox(
        fit: BoxFit.contain,
        child: Icon(
          Icons.hexagon,
          color: MXCColors.hexStringToColor(nftData!),
        ),
      );

    case NFTItemType.withoutImage:
      return Container(
        padding: const EdgeInsets.all(Sizes.space2XSmall),
        color: ColorsTheme.of(context).darkGray,
        child: Text(
          appName,
          style: FontTheme.of(context).logo(),
        ),
      );
    case NFTItemType.localImage:
      return Image(
        image: AssetImage(
          nftData!,
        ),
        fit: BoxFit.fill,
        errorBuilder: imageErrorBuilder,
        loadingBuilder: imageLoadingBuilder,
      );
    default:
      return Image.network(
        '${state.ipfsGateway}$nftData',
        fit: BoxFit.fill,
        errorBuilder: imageErrorBuilder,
        loadingBuilder: imageLoadingBuilder,
      );
  }
}

class NFTItem extends HookConsumerWidget {
  const NFTItem({
    super.key,
    required this.imageUrl,
    this.size,
  });

  final String? imageUrl;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioContainer.state);
    final nftItemType = getNFTItemType(imageUrl);
    return SizedBox(
      height: size ?? 105,
      width: size ?? 105,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: getNFTWidget(state, context, nftItemType, imageUrl)),
    );
  }
}
