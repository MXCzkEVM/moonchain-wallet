import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/portfolio/presentation/portfolio_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

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
    final pattern = RegExp(r'^\w+\.\w+$');
    final isDomainName =pattern.hasMatch(imageUrl?? '');
    return SizedBox(
      height: size ?? 105,
      width: size ?? 105,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: state.ipfsGateway != null && imageUrl != null
            ? imageUrl!.startsWith('#')
                ? FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                      Icons.hexagon,
                      color: MXCColors.hexStringToColor(imageUrl!),
                    ),
                )
                : isDomainName ? Container(
                                        
                                        decoration: BoxDecoration(
                                          color: ColorsTheme.of(context).layerSheetBackground,
                                          borderRadius: UIConfig.defaultBorderRadiusAll
                                        ),
                  child: FittedBox(
                  fit: BoxFit.contain,
                    child: Center(
                      child: Text(
                        imageUrl!,
                          style: FontTheme.of(context).body1.textWhite(),
                        ),
                    ),
                  ),
                ) : Image.network(
                    '${state.ipfsGateway}$imageUrl',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Text(
                      error.toString(),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
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
                    },
                  )
            : Container(
                padding: const EdgeInsets.all(Sizes.space2XSmall),
                color: ColorsTheme.of(context).darkGray,
                child: Image(image: ImagesTheme.of(context).appTextLogo)),
      ),
    );
  }
}
