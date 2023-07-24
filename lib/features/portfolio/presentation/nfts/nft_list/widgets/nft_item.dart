import 'package:flutter/material.dart';

class NFTItem extends StatelessWidget {
  final String imageUrl;
  const NFTItem({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      width: 105,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          'https://ipfs.io/ipfs/$imageUrl',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
