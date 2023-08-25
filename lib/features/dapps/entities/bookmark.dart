import 'dart:io';

import 'package:mxc_logic/mxc_logic.dart';

class Bookmark extends Dapp {
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.image,
  });

  final int id;
  final String title;
  final String url;
  final String? description;
  final String? image;

  // static List<Bookmark> fixedBookmarks() {
  //   return [
  //     const Bookmark(
  //       id: 5,
  //       title: 'MXC zkEVM explorer',
  //       description: 'Welcome to MXC zkEVM explorer',
  //       url: 'https://explorer.mxc.com',
  //       image: 'assets/images/apps/explorer-medium.png',
  //       editable: false,
  //       occupyGrid: 8,
  //     ),
  //     const Bookmark(
  //       id: 1,
  //       title: 'Bridge',
  //       description: '& Faucet',
  //       url: 'https://wannsee-bridge.mxc.com',
  //       image: 'assets/images/apps/bridge-medium.png',
  //       editable: false,
  //       occupyGrid: 8,
  //     ),
  //     const Bookmark(
  //       id: 2,
  //       title: 'Stablecoin',
  //       description: 'world_un_depeggable',
  //       url: 'https://wannsee-xsd.mxc.com',
  //       image: 'assets/images/apps/xsd-medium.png',
  //       editable: false,
  //       occupyGrid: 8,
  //     ),
  //     const Bookmark(
  //       id: 3,
  //       title: 'MNS',
  //       description: 'Own your .MXC domain',
  //       url: 'https://wannsee-mns.mxc.com',
  //       image: 'assets/images/apps/mns-small.png',
  //       editable: false,
  //       occupyGrid: 4,
  //     ),
  //     Bookmark(
  //       id: 4,
  //       title: 'NFT',
  //       description: 'digitalize_your_assets',
  //       url: 'https://wannsee-nft.mxc.com',
  //       image: 'assets/images/apps/nft-small.png',
  //       editable: false,
  //       occupyGrid: 4,
  //       visible: Platform.isAndroid,
  //     ),
  //   ];
  // }
}
