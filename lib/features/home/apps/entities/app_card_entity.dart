import 'package:flutter/material.dart';

enum CardContentAlgin { center, topCenter, leftBottom }

enum CardAxis { horizontal, vertical }

enum CardSize { samll, medium, large }

class AppCardEntity {
  AppCardEntity({
    required this.name,
    required this.description,
    this.image,
    this.direction = CardAxis.horizontal,
    this.size = CardSize.medium,
    this.contentAlgin = CardContentAlgin.center,
    required this.url,
    this.nameColor,
    this.backgroundColor,
    this.backgroundGradient,
    this.imageWidth,
    this.imageHeight,
    this.imagePositionTop,
    this.imagePositionbottom,
    this.imagePositionLeft,
    this.imagePositionRight,
  });

  final String name;
  final String description;
  final String? image;
  final CardAxis direction;
  final CardSize size;
  final CardContentAlgin contentAlgin;
  final String url;
  final List<Color>? nameColor;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final double? imageWidth;
  final double? imageHeight;
  final double? imagePositionTop;
  final double? imagePositionbottom;
  final double? imagePositionLeft;
  final double? imagePositionRight;

  static List<AppCardEntity> getAppCards() {
    return [
      AppCardEntity(
        name: 'MXC Swap',
        description: 'Diversify your portfolio',
        image: 'assets/svg/apps/mxc_swap.svg',
        direction: CardAxis.vertical,
        size: CardSize.large,
        url: 'https://wannsee-swap.mxc.com',
        nameColor: const [
          Color(0xFF68B6F6),
          Color(0xFF9EF76B),
        ],
        backgroundGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF1B3544),
            Color(0xFF355B35),
          ],
          tileMode: TileMode.mirror,
        ),
        imageHeight: 90,
        imagePositionbottom: 30,
        imagePositionRight: 0,
        imagePositionLeft: 0,
      ),
      AppCardEntity(
        name: 'Bridge',
        description: '& Faucet',
        image: '',
        direction: CardAxis.horizontal,
        size: CardSize.large,
        url: 'https://wannsee-bridge.mxc.com',
        nameColor: const [
          Color(0xFFB3F864),
          Color(0xFFE8944B),
        ],
        imageHeight: 80,
        imagePositionbottom: 0,
        imagePositionRight: 0,
      ),
      AppCardEntity(
        name: 'Stablecoin',
        description: 'World’s first un-depeggable',
        image: '',
        direction: CardAxis.horizontal,
        size: CardSize.medium,
        url: 'https://wannsee-xsd.mxc.com',
        nameColor: const [
          Color(0xFF87C460),
          Color(0xFFEDDE5C),
        ],
      ),
      AppCardEntity(
        name: 'NFT',
        description: 'Digitalize your assets',
        image: '',
        direction: CardAxis.horizontal,
        size: CardSize.medium,
        url: 'https://wannsee-nft.mxc.com',
      ),
      AppCardEntity(
        name: 'ENS',
        description: 'Own your .MXC domain',
        image: '',
        direction: CardAxis.horizontal,
        size: CardSize.medium,
        url: 'https://wannsee-mns.mxc.com',
        nameColor: const [
          Color(0xFF44A7EA),
          Color(0xFF3DA41D),
        ],
      ),
      AppCardEntity(
        name: 'ISO Launchpad',
        description: 'Accelerating IOT',
        image: 'assets/images/apps/spacecraft.png',
        direction: CardAxis.vertical,
        size: CardSize.large,
        url: 'https://wannsee-mns.mxc.com',
        nameColor: const [
          Color(0xFF20FFFF),
          Color(0xFF4A2E60),
        ],
        backgroundGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF8D023F),
            Color(0xFF09379E),
          ],
          tileMode: TileMode.mirror,
        ),
        imageHeight: 126,
        imagePositionbottom: 0,
        imagePositionRight: 0,
        imagePositionLeft: 0,
      ),
      AppCardEntity(
        name: 'Explorer',
        description: 'Visualize Blockchain',
        image: '',
        direction: CardAxis.horizontal,
        size: CardSize.large,
        url: 'https://wannsee-explorer.mxc.com',
      ),
    ];
  }
}
