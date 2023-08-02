import 'package:datadashwallet/features/portfolio/presentation/portfolio_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NFTItem extends HookConsumerWidget {
  const NFTItem({
    super.key,
    required this.imageUrl,
    this.size,
  });

  final String imageUrl;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioContainer.state);
    return SizedBox(
      height: size ?? 105,
      width: size ?? 105,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: state.ipfsGateway != null
            ? Image.network(
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
            : Container(),
      ),
    );
  }
}
