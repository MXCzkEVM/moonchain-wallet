class NFT {
  const NFT(
      {required this.address,
      required this.tokenId,
      required this.image,
      required this.name});

  final String address;
  final String tokenId;
  final String image;
  final String name;
}
