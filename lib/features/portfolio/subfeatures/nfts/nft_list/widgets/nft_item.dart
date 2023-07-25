import 'package:flutter/material.dart';

class NFTItem extends StatelessWidget {
  const NFTItem({
    super.key,
    required this.imageUrl,
    this.size,
  });

  final String imageUrl;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 105,
      width: size ?? 105,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          'https://ipfs.io/ipfs/$imageUrl',
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
        ),
      ),
    );
  }
}
