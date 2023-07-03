class DApp {
  DApp({
    required this.name,
    required this.url,
    this.description,
    this.image,
  });

  final String name;
  final String? description;
  final String url;
  final String? image;

  static List<DApp> fixedBookmarks() {
    return [
      DApp(
        name: 'Explorer',
        url: 'https://wannsee-explorer.mxc.com',
        description: 'Visualize Blockchain',
        image: 'assets/images/apps/stable_coin.png',
      ),
      DApp(
        name: 'Stablecoin',
        url: 'https://wannsee-xsd.mxc.com',
        description: 'World’s first un-depeggable',
        image: 'assets/images/apps/stable_coin.png',
      ),
      DApp(
        name: 'NFT',
        url: 'https://wannsee-nft.mxc.com',
        description: 'Digitalize your assets',
        image: 'assets/images/apps/stable_coin.png',
      ),
      DApp(
        name: 'MNS',
        url: 'https://wannsee-mns.mxc.com',
        description: 'Own your .MXC domain',
        image: 'assets/images/apps/stable_coin.png',
      ),
    ];
  }
}
